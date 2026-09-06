# Interactive command replacements. Every replacement is conditional on its
# executable being present, so this file behaves the same on a machine with
# none of them installed: the platform commands stay in place.
() {
    local command_name executable

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

    ## Editable fallback lists ###############################################

    # Candidates are executable names, ordered from most preferred to last.
    # macOS: modern replacement -> GNU tool -> platform default.
    # Linux: modern replacement -> default command (no g-prefixed detour).
    # Add a command row or insert a compatible replacement into its list.
    # Do not substitute tools with incompatible command-line interfaces here.
    local -A macos_fallbacks=(
        ls        'eza gls ls'
        vim       'nvim vim'
        vi        'nvim vi'
        sed       'gsed sed'
        grep      'ggrep grep'
        find      'gfind find'
        xargs     'gxargs xargs'
        tar       'gtar tar'
        dircolors 'gdircolors dircolors'
    )
    local -A linux_fallbacks=(
        ls        'eza ls'
        vim       'nvim vim'
        vi        'nvim vi'
        sed       'sed'
        grep      'grep'
        find      'find'
        xargs     'xargs'
        tar       'tar'
        dircolors 'dircolors'
    )
    local -A fallbacks selected
    case $OSTYPE in
        darwin*) fallbacks=("${(@kv)macos_fallbacks}");;
        linux*)  fallbacks=("${(@kv)linux_fallbacks}");;
        *)       fallbacks=(ls ls);;
    esac

    local candidates
    for command_name candidates in "${(@kv)fallbacks}"; do
        for executable in ${=candidates}; do
            # An open shell can retain a command hash after an uninstall.
            if (( $+commands[$executable] )) && [[ -x ${commands[$executable]} ]]; then
                selected[$command_name]=$executable
                break
            fi
        done
    done

    ## ls flags and shortcuts ################################################

    # eza's -h means --header, while ls uses it for human-readable sizes.
    # Keep these presets separate instead of chaining shortcuts through ls.
    local ls_cmd long_flags=-lh all_flags=-lah
    case ${selected[ls]:-} in
        eza)
            ls_cmd='eza --color=auto --group-directories-first'
            long_flags=-l all_flags=-la
            ;;
        gls) ls_cmd='gls --color=auto --group-directories-first';;
        ls)
            case $OSTYPE in
                darwin*) export CLICOLOR=1; ls_cmd='ls -G';;
                # BusyBox supports --color but not --group-directories-first.
                linux*) ls_cmd='ls --color=auto';;
                *) ls_cmd=ls;;
            esac
            ;;
        # A newly listed implementation gets standard flags by default;
        # add a preset above if it needs its own flags.
        *) ls_cmd=${selected[ls]:-};;
    esac
    if [[ -n $ls_cmd ]]; then
        _dot_alias ls "$ls_cmd"
        _dot_alias l  "$ls_cmd -1"
        _dot_alias ll "$ls_cmd $long_flags"
        _dot_alias la "$ls_cmd $all_flags"
    fi

    for command_name executable in "${(@kv)selected}"; do
        [[ $command_name == (ls|dircolors) ]] && continue
        [[ $command_name == $executable ]] && continue
        _dot_alias "$command_name" "$executable"
    done

    ## Colours ###############################################################

    # GNU ls and eza both read LS_COLORS; GNU dircolors is optional on every
    # platform. Its output depends on the executable and terminal, so it goes
    # through the same cache as the other tool init scripts rather than forking
    # once per interactive shell.
    local dircolors_cmd=${selected[dircolors]:-}
    if [[ -n $dircolors_cmd ]]; then
        source "$DOT_ZSH_DIR/lib/toolcache.zsh"
        _dot_source_tool_init dircolors "$dircolors_cmd" "$dircolors_cmd" -b
    fi

    unfunction _dot_alias
}
