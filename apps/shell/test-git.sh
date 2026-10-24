#!/bin/bash
# Run with bash or zsh; uses only temporary local repositories and no hooks.
set -eu
git_test_lib=${1:?Pass the absolute path to apps/shell/lib.sh}
git_test_dir=$(mktemp -d)
trap 'rm -rf -- "$git_test_dir"' EXIT
export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null GIT_TERMINAL_PROMPT=0
export GIT_CONFIG_COUNT=0
unset GIT_CONFIG_PARAMETERS GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_COMMON_DIR
unset GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES
export GIT_AUTHOR_NAME=alice GIT_AUTHOR_EMAIL=alice@example.test
export GIT_COMMITTER_NAME=alice GIT_COMMITTER_EMAIL=alice@example.test
source "$git_test_lib"
if [ -n "${ZSH_VERSION:-}" ]; then
    typeset -ga _DOT_ZSH_MANAGED_ALIASES=()
fi

assert_eq() {
    if [ "$1" != "$2" ]; then
        printf 'FAIL: %s\n' "$3" >&2
        exit 1
    fi
}
expect_fail() {
    if "$@" >"$git_test_dir/failure.log" 2>&1; then
        printf 'FAIL: expected %s to fail\n' "$1" >&2
        exit 1
    fi
}
remote_head() { command git --git-dir="$git_test_dir/$1.git" rev-parse "refs/heads/$2"; }
commit_file() {
    printf '%s\n' "$2" > "$1"
    command git add -- "$1"
    command git commit -qm "$2"
}

cd "$git_test_dir"
command git init -q --bare origin.git
command git init -q --bare backup.git
command git init -q repo
cd repo
command git symbolic-ref HEAD refs/heads/topic/demo
expect_fail gps
command grep -q 'no commits' "$git_test_dir/failure.log"
commit_file seed.txt seed
command git remote add origin ../origin.git
command git remote add backup ../backup.git
command git config push.autoSetupRemote true
command git branch side
command git push -q origin refs/heads/side
side_head=$(remote_head origin side)

# Dry runs neither publish a branch nor write upstream configuration.
gps --dry-run >/dev/null 2>&1
gpsu -n >/dev/null 2>&1
expect_fail command git --git-dir=../origin.git show-ref --verify refs/heads/topic/demo
expect_fail command git config --get branch.topic/demo.remote
gps >/dev/null 2>&1
assert_eq "$(remote_head origin topic/demo)" "$(command git rev-parse HEAD)" 'publish current branch'
expect_fail command git config --get branch.topic/demo.remote

# Explicit refs ignore push defaults, custom refspecs and a same-named tag.
command git tag -a topic/demo -m 'same name'
command git config push.default matching
command git config push.followTags true
command git config remote.origin.push refs/heads/topic/demo:refs/heads/side
command git config branch.topic/demo.remote backup
command git config branch.topic/demo.merge refs/heads/side
commit_file local.txt local
gps >/dev/null 2>&1
assert_eq "$(remote_head origin topic/demo)" "$(command git rev-parse HEAD)" 'push ignores upstream'
assert_eq "$(remote_head origin side)" "$side_head" 'other branch untouched'
expect_fail command git --git-dir=../origin.git show-ref --verify refs/tags/topic/demo
assert_eq "$(command git config branch.topic/demo.remote)" backup 'gps preserves upstream'
gpsu backup >/dev/null 2>&1
assert_eq "$(remote_head backup topic/demo)" "$(command git rev-parse HEAD)" 'explicit remote'
assert_eq "$(command git config branch.topic/demo.remote)" backup 'set upstream remote'
assert_eq "$(command git config branch.topic/demo.merge)" refs/heads/topic/demo 'set upstream branch'

command git clone -q --no-checkout ../origin.git ../peer
command git -C ../peer checkout -qb topic/demo --track origin/topic/demo
(
    cd ../peer
    commit_file remote.txt remote
    command git push -q origin refs/heads/topic/demo:refs/heads/topic/demo
)
command git config pull.rebase true
gpl >/dev/null 2>&1
assert_eq "$(command git rev-parse HEAD)" "$(remote_head origin topic/demo)" 'pull ignores different upstream'

# Divergence must stop without changing HEAD; rebase is an explicit choice.
commit_file local-only.txt local-only
before=$(command git rev-parse HEAD)
(
    cd ../peer
    commit_file remote-only.txt remote-only
    command git push -q origin refs/heads/topic/demo:refs/heads/topic/demo
)
expect_fail gpl
assert_eq "$(command git rev-parse HEAD)" "$before" 'ff-only rejects divergence'
expect_fail gps
command git config pull.ff only
gpr >/dev/null 2>&1
command git merge-base --is-ancestor "$(remote_head origin topic/demo)" HEAD
assert_eq "$(cat local-only.txt)" local-only 'rebase keeps local changes'
gpsu >/dev/null 2>&1
assert_eq "$(command git config branch.topic/demo.remote)" origin 'replace upstream'

# Pull from an explicitly selected remote, with the upstream still on origin.
command git -C ../peer remote add backup ../backup.git
(
    cd ../peer
    command git fetch -q origin
    command git reset -q --hard origin/topic/demo
    commit_file backup.txt backup
    command git push -q backup refs/heads/topic/demo:refs/heads/topic/demo
)
gpl backup >/dev/null 2>&1
assert_eq "$(command git rev-parse HEAD)" "$(remote_head backup topic/demo)" 'pull explicit remote'

# Even when Git enables autostash globally, dirty files are left for the user.
command git config merge.autoStash true
command git config rebase.autoStash true
printf 'dirty\n' > seed.txt
(
    cd ../peer
    commit_file seed.txt updated
    command git push -q backup refs/heads/topic/demo:refs/heads/topic/demo
)
before=$(command git rev-parse HEAD)
expect_fail gpl backup
expect_fail gpr backup
assert_eq "$(command git rev-parse HEAD)" "$before" 'dirty pull leaves HEAD'
assert_eq "$(cat seed.txt)" dirty 'dirty pull preserves file'
command git checkout -q -- seed.txt
command git tag -d topic/demo >/dev/null

# Invalid calls fail before any push, including detached HEAD and bare repos.
expect_fail gps --force
expect_fail gps origin backup
expect_fail gps ''
expect_fail gpl --dry-run
expect_fail gpl missing-remote
command git checkout -qb topic/missing
expect_fail gpl
command git checkout -q topic/demo
command git checkout -q --detach
for shortcut in gpl gpr gps gpsu; do
    expect_fail "$shortcut"
    command grep -q 'detached HEAD' "$git_test_dir/failure.log"
done
command git checkout -q topic/demo
(
    cd ../origin.git
    expect_fail gps
)
(
    cd ..
    expect_fail gpl
)

# Linked worktrees resolve their own branch, not the main checkout's branch.
command git worktree add -q ../worktree -b topic/worktree
(
    cd ../worktree
    gpsu >/dev/null 2>&1
    assert_eq "$(remote_head origin topic/worktree)" "$(command git rev-parse HEAD)" 'linked worktree branch'
)
for shortcut in gpl gpr gps gpsu; do
    "$shortcut" --help | command grep -q "usage: $shortcut"
    dgscmds git | command grep -q "$shortcut"
done

# Load aliases with a minimal candidate table to avoid optional tool init.
mkdir -p "$git_test_dir/aliases/apps/shell" "$git_test_dir/aliases/apps/bash"
printf 'git|git|git\n' > "$git_test_dir/aliases/apps/shell/fallbacks"
DOT_DIR=$git_test_dir/aliases
# Used by the dynamically sourced Bash alias file.
# shellcheck disable=SC2034
DOT_BASH_DIR=$DOT_DIR/apps/bash
if [ -n "${ZSH_VERSION:-}" ]; then
    git_test_aliases=${git_test_lib%/shell/lib.sh}/zsh/core/aliases.zsh
else
    git_test_aliases=${git_test_lib%/shell/lib.sh}/bash/aliases.bash
fi
source "$git_test_aliases"
for shortcut in g gst ga gc gf gsw gswc gb gss glog glg gd gds gdv gdvs; do
    alias "$shortcut" >/dev/null
done
# Enable aliases for this fixed invocation in non-interactive Bash too.
if [ -n "${BASH_VERSION:-}" ]; then shopt -s expand_aliases; fi
eval 'glg --no-color -5' > "$git_test_dir/graph.log"
command grep -Fq '*' "$git_test_dir/graph.log"
command grep -Fq 'topic/worktree' "$git_test_dir/graph.log"
command grep -Fq 'alice' "$git_test_dir/graph.log"
before=$(_dot_managed_aliases)
source "$git_test_aliases"
assert_eq "$(_dot_managed_aliases)" "$before" 'reload preserves aliases'
printf '' > "$DOT_DIR/apps/shell/fallbacks"
source "$git_test_aliases"
for shortcut in g gst ga gc gf gsw gswc gb glg; do
    expect_fail alias "$shortcut"
done
printf 'Git shortcut checks passed (%s)\n' "${ZSH_VERSION:-Bash $BASH_VERSION}"
