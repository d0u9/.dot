# Interactive command replacements. Add or replace a key/value pair to prefer
# another implementation; remove the pair to return to the system command.
# Values may include default arguments. Missing replacements are ignored.
() {
    local command_name replacement executable

    # Re-sourcing this file must also remove aliases that were deleted from
    # the table or whose replacement command has disappeared.
    if (( ${+_DOT_ZSH_MANAGED_ALIASES} )); then
        for command_name in "${_DOT_ZSH_MANAGED_ALIASES[@]}"; do
            unalias "$command_name" 2>/dev/null
        done
    fi
    typeset -ga _DOT_ZSH_MANAGED_ALIASES=()

    local -A preferred_commands=(
        ls    'gls --color=auto'
        sed   gsed
        grep  ggrep
        find  gfind
        xargs gxargs
        tar   gtar
    )

    for command_name replacement in ${(kv)preferred_commands}; do
        executable=${replacement%% *}
        if (( $+commands[$executable] )); then
            alias "$command_name=$replacement"
            _DOT_ZSH_MANAGED_ALIASES+=("$command_name")
        fi
    done

    # Colour the system ls when GNU ls was not selected above.
    if (( ! $+aliases[ls] )); then
        case "$OSTYPE" in
            darwin*)
                export CLICOLOR=1
                alias ls='ls -G'
                _DOT_ZSH_MANAGED_ALIASES+=(ls)
                ;;
            linux*)
                alias ls='ls --color=auto'
                _DOT_ZSH_MANAGED_ALIASES+=(ls)
                ;;
        esac
    fi

    # GNU ls reads LS_COLORS; GNU dircolors is optional on every platform.
    if (( $+commands[dircolors] )); then
        eval "$(dircolors -b)"
    fi

    alias l='ls -1'
    alias ll='ls -lh'
    alias la='ls -lah'
    _DOT_ZSH_MANAGED_ALIASES+=(l ll la)
}
