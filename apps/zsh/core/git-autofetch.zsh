# Fetch the current branch's upstream remote in the background, so the prompt's
# ⇣ incoming marker reflects the upstream without a manual `git fetch`.
#
# Runs from precmd, at most once every DOT_GIT_AUTOFETCH_INTERVAL seconds per
# worktree (default 300; 0 turns it off). The throttle is the mtime of that
# worktree's FETCH_HEAD, which every fetch -- manual or automatic -- rewrites,
# so a fetch you just ran yourself also counts. Finding the repository and
# reading that mtime is done with builtins only; a prompt outside a repository,
# or inside one fetched recently, forks nothing.
#
# The fetch never prompts: no terminal credential prompt, and ssh in batch mode,
# so a remote that needs a password or an unlocked key simply fails quietly.
# The result shows up on the next prompt that follows its completion.

typeset -g DOT_GIT_AUTOFETCH_INTERVAL=${DOT_GIT_AUTOFETCH_INTERVAL:-300}

_dot_git_autofetch() {
    emulate -L zsh -o no_bg_nice
    (( DOT_GIT_AUTOFETCH_INTERVAL > 0 )) || return 0

    # Walk up to the nearest .git, as git itself would.
    local dir=$PWD gitdir
    while true; do
        if [[ -e $dir/.git ]]; then
            gitdir=$dir/.git
            break
        fi
        [[ $dir == / ]] && return 0
        dir=${dir:h}
    done

    # Worktrees and submodules have a .git file pointing at their own git dir.
    # FETCH_HEAD is per worktree; only config is in the shared directory.
    if [[ -f $gitdir ]]; then
        local line
        read -r line < $gitdir || return 0
        [[ $line == 'gitdir: '* ]] || return 0
        gitdir=${line#gitdir: }
        [[ $gitdir == /* ]] || gitdir=$dir/$gitdir
    fi
    [[ -d $gitdir ]] || return 0

    zmodload -F zsh/stat b:zstat 2>/dev/null || return 0
    zmodload -F zsh/datetime p:EPOCHSECONDS 2>/dev/null || return 0
    local -a mtime
    if zstat -A mtime +mtime -- $gitdir/FETCH_HEAD 2>/dev/null &&
       (( EPOCHSECONDS - mtime[1] < DOT_GIT_AUTOFETCH_INTERVAL )); then
        return 0
    fi

    # Ask Git for the configured upstream so include/includeIf configuration
    # works. Only the tracked remote is needed for the prompt's arrows.
    # These commands run only after the repository's fetch interval elapses.
    local branch remote
    branch=$(git -C $dir symbolic-ref --quiet --short HEAD 2>/dev/null) || return 0
    remote=$(git -C $dir config --get "branch.$branch.remote" 2>/dev/null) || return 0
    [[ -n $remote && $remote != . ]] || return 0
    git -C $dir remote get-url $remote &>/dev/null || return 0

    # Touch first so the next prompts, and other shells in the same
    # repository, do not start a second fetch while this one runs.
    touch -- $gitdir/FETCH_HEAD 2>/dev/null

    # &! disowns the job: no job-control notice, and no "you have running
    # jobs" when the shell exits.
    GIT_TERMINAL_PROMPT=0 \
    GIT_SSH_COMMAND=${GIT_SSH_COMMAND:-ssh -o BatchMode=yes -o ConnectTimeout=5} \
        git -C $dir fetch --quiet --no-tags $remote \
        </dev/null &>/dev/null &!
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _dot_git_autofetch
