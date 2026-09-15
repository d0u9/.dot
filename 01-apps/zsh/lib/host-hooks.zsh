# Source every readable host hook for one startup phase. A hook is selected by
# its suffix; the leading name is only a convenient place for ordering and
# description. Both .sh and .zsh are accepted because these files are sourced
# by Zsh regardless of their extension.
_dot_source_host_hooks() {
    emulate -L zsh

    local phase=$1 hook
    local -a hooks
    [[ $phase == (pre|post) ]] || return 1

    hooks=(
        "$DOT_ZSH_DIR"/host-conf/*-"$phase".sh(N)
        "$DOT_ZSH_DIR"/host-conf/*-"$phase".zsh(N)
    )
    hooks=("${(@on)hooks}")

    for hook in "${hooks[@]}"; do
        [[ -f $hook && -r $hook ]] || continue
        source "$hook"
    done
}
