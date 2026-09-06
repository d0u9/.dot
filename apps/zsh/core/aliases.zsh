# Interactive command replacements. Every replacement is conditional on its
# executable being present, so this file behaves the same on a machine with
# none of them installed: the platform commands stay in place.
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

    # Define an alias and remember it, so the cleanup above can find it again.
    _dot_alias() {
        alias "$1=$2"
        _DOT_ZSH_MANAGED_ALIASES+=("$1")
    }

    ## ls ####################################################################

    # eza first, then GNU coreutils ls, then whatever the platform ships.
    #
    # Each variant declares its own l/ll/la rather than chaining them through
    # the `ls` alias. The flags are not interchangeable: `-h` is
    # human-readable sizes for both ls implementations but `--header` for eza,
    # which prints sizes in human units anyway, so a chained `ll='ls -lh'`
    # would quietly mean something different depending on which binary was
    # found. `--group-directories-first` exists in eza and GNU ls but not in
    # the BSD ls that macOS ships.
    local ls_cmd
    if (( $+commands[eza] )); then
        ls_cmd='eza --color=auto --group-directories-first'
        _dot_alias ls "$ls_cmd"
        _dot_alias l  "$ls_cmd -1"
        _dot_alias ll "$ls_cmd -l"
        _dot_alias la "$ls_cmd -la"
    elif (( $+commands[gls] )); then
        ls_cmd='gls --color=auto --group-directories-first'
        _dot_alias ls "$ls_cmd"
        _dot_alias l  "$ls_cmd -1"
        _dot_alias ll "$ls_cmd -lh"
        _dot_alias la "$ls_cmd -lah"
    else
        case "$OSTYPE" in
            darwin*)
                # BSD ls colours with -G; CLICOLOR covers the callers that do
                # not go through the alias.
                export CLICOLOR=1
                ls_cmd='ls -G'
                ;;
            linux*)
                # Only --color here: this branch is reached when coreutils is
                # absent, which on Alpine means busybox ls, and busybox does
                # not implement --group-directories-first.
                ls_cmd='ls --color=auto'
                ;;
            *)
                # An ls of unknown provenance: no flags beyond the standard
                # ones, so nothing here can fail on it.
                ls_cmd='ls'
                ;;
        esac
        _dot_alias ls "$ls_cmd"
        _dot_alias l  "$ls_cmd -1"
        _dot_alias ll "$ls_cmd -lh"
        _dot_alias la "$ls_cmd -lah"
    fi

    ## Other GNU replacements ################################################

    # Add or remove a key/value pair to prefer another implementation or to
    # return to the system command. Values may include default arguments.
    local -A preferred_commands=(
        sed   gsed
        grep  ggrep
        find  gfind
        xargs gxargs
        tar   gtar
    )

    for command_name replacement in ${(kv)preferred_commands}; do
        executable=${replacement%% *}
        if (( $+commands[$executable] )); then
            _dot_alias "$command_name" "$replacement"
        fi
    done

    ## Colours ###############################################################

    # GNU ls and eza both read LS_COLORS; GNU dircolors is optional on every
    # platform. Its output only changes when dircolors itself does, so it goes
    # through the same cache as the other tool init scripts rather than forking
    # once per interactive shell.
    if (( $+commands[dircolors] )); then
        source "$DOT_ZSH_DIR/lib/toolcache.zsh"
        _dot_source_tool_init dircolors dircolors dircolors -b
    fi

    unfunction _dot_alias
}
