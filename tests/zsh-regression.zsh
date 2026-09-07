#!/usr/bin/env zsh
# Isolated checks: no user startup files, installed plugins or private hooks.
emulate -LR zsh
setopt err_exit pipe_fail

repo=${0:A:h:h}
scratch=$(mktemp -d "${TMPDIR:-/tmp}/dot-zsh-test.XXXXXXXX")
trap 'rm -rf -- "$scratch"' EXIT
export HOME=$scratch/home XDG_CACHE_HOME=$scratch/cache
export XDG_DATA_HOME=$scratch/data XDG_STATE_HOME=$scratch/state
mkdir -p "$HOME" "$scratch/bin"
export PATH=$scratch/bin:/usr/bin:/bin
DOT_ZSH_DIR=$repo/apps/zsh
DOT_ZSH_PLUGIN_DIR=$scratch/plugins

hook_root=$scratch/hook-root
mkdir -p "$hook_root/host-conf"
for spec in \
    '30-third-pre.zsh:third' \
    '10-first-pre.sh:first' \
    '20-second-pre.zsh:second' \
    '40-fourth-post.sh:fourth' \
    'ignored.sh:ignored'; do
    file=${spec%%:*}
    value=${spec#*:}
    print -r -- "hook_order+=($value)" > "$hook_root/host-conf/$file"
done
source "$repo/apps/zsh/lib/host-hooks.zsh"
DOT_ZSH_DIR=$hook_root
hook_order=()
_dot_source_host_hooks pre
[[ ${(j: :)hook_order} == 'first second third' ]]
_dot_source_host_hooks post
[[ ${(j: :)hook_order} == 'first second third fourth' ]]
if _dot_source_host_hooks middle; then
    print -u2 'FAIL: invalid host hook phase was accepted'; exit 1
fi
unfunction _dot_source_host_hooks
DOT_ZSH_DIR=$repo/apps/zsh
print 'PASS: host hooks match suffixes and load in lexical order'

cat > "$scratch/bin/gdircolors" <<'EOF'
#!/bin/sh
printf "export LS_COLORS='%s:%s'\n" "$TERM" "$COLORTERM"
EOF
cat > "$scratch/bin/zoxide" <<'EOF'
#!/bin/sh
[ ! -f "$HOME/fail-init" ] || exit 1
printf '%s\n' '__zoxide_hook() { : original-hook; }'
EOF
chmod +x "$scratch/bin/"*
rehash

export TERM=dumb COLORTERM=
OSTYPE=darwin
source "$DOT_ZSH_DIR/core/aliases.zsh"
[[ $LS_COLORS == dumb: ]]
export TERM=xterm-256color COLORTERM=truecolor
source "$DOT_ZSH_DIR/core/aliases.zsh"
[[ $LS_COLORS == xterm-256color:truecolor ]]
print 'PASS: gdircolors discovery and terminal cache invalidation'

for tool in eza gls gsed nvim tree; do
    print '#!/bin/sh' > "$scratch/bin/$tool"
    chmod +x "$scratch/bin/$tool"
done
rehash
source "$DOT_ZSH_DIR/core/aliases.zsh"
[[ $aliases[ls] == 'eza '* && $aliases[sed] == gsed ]]
[[ $aliases[tree] == 'eza --tree' ]]
[[ $aliases[vim] == nvim && $aliases[vi] == nvim ]]
OSTYPE=linux-gnu
source "$DOT_ZSH_DIR/core/aliases.zsh"
[[ $aliases[ls] == 'eza '* && ${+aliases[sed]} == 0 ]]
[[ $aliases[tree] == 'eza --tree' ]]
[[ $aliases[vim] == nvim && $aliases[vi] == nvim ]]
rm "$scratch/bin/nvim"
source "$DOT_ZSH_DIR/core/aliases.zsh"
[[ ${+aliases[vim]} == 0 && ${+aliases[vi]} == 0 ]]
print 'PASS: vim/vi prefer nvim and restore defaults after removal'
rm "$scratch/bin/eza"
source "$DOT_ZSH_DIR/core/aliases.zsh"
[[ $aliases[ls] == 'ls --color=auto' && ${+aliases[tree]} == 0 ]]
rm "$scratch/bin/tree"
source "$DOT_ZSH_DIR/core/aliases.zsh"
[[ ${+aliases[tree]} == 0 ]]
OSTYPE=darwin
source "$DOT_ZSH_DIR/core/aliases.zsh"
[[ $aliases[ls] == 'gls '* ]]
rm "$scratch/bin/gls" "$scratch/bin/gsed"
source "$DOT_ZSH_DIR/core/aliases.zsh"
[[ $aliases[ls] == 'ls -G' && ${+aliases[sed]} == 0 ]]
print 'PASS: macOS/Linux fallback priorities and stale alias removal'

# Even a matching cached script must not run once its tool is missing.
producer() { print 'missing_init_ran=yes'; }
_dot_source_tool_init absent gdircolors producer
unset missing_init_ran
rm "$scratch/bin/gdircolors"
# Deliberately keep the command hash, as an already-open shell would.
if _dot_source_tool_init absent gdircolors producer; then
    print -u2 'FAIL: missing executable was accepted'; exit 1
fi
[[ ${+missing_init_ran} == 0 ]]
print 'PASS: missing executable skips cached initialization'

producer() { print false; }
if _dot_source_tool_init failure zsh producer; then
    print -u2 'FAIL: fresh init failure was hidden'; exit 1
fi
if _dot_source_tool_init failure zsh producer; then
    print -u2 'FAIL: cached init failure was hidden'; exit 1
fi
print 'PASS: fresh and cached initialization failure status'

producer() { print -r -- "init_arg_count=$#"; }
_dot_source_tool_init arguments zsh producer 'a b'
[[ $init_arg_count == 1 ]]
_dot_source_tool_init arguments zsh producer a b
[[ $init_arg_count == 2 ]]
print 'PASS: cache keys preserve argument boundaries'

source "$DOT_ZSH_DIR/core/integrations.zsh"
original=$functions[_dot_zoxide_add]
source "$DOT_ZSH_DIR/core/integrations.zsh"
[[ $functions[_dot_zoxide_add] == $original ]]
touch "$HOME/fail-init"
rm "$XDG_CACHE_HOME/zsh/zoxide-init.zsh"
source "$DOT_ZSH_DIR/core/integrations.zsh"
[[ $functions[_dot_zoxide_add] == $original ]]
print 'PASS: successful and failed zoxide reinitialization preserve original hook'

p10k() {
    snapshot=$POWERLEVEL9K_VCS_CONTENT_EXPANSION
    integration=$POWERLEVEL9K_TERM_SHELL_INTEGRATION
}
source "$DOT_ZSH_DIR/core/p10k.zsh"
[[ $snapshot == $POWERLEVEL9K_VCS_CONTENT_EXPANSION ]]
[[ $integration == true ]]
print 'PASS: prompt reload sees all custom settings'
