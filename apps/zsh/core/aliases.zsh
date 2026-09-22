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
    if (( ${+_DOT_ZSH_MANAGED_PORTS} )); then
        unfunction ports 2>/dev/null
        unset _DOT_ZSH_MANAGED_PORTS _DOT_ZSH_PORTS_COMMAND
    fi

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
        tree      'eza tree'
        vim       'nvim vim'
        vi        'nvim vi'
        sed       'gsed sed'
        grep      'ggrep grep'
        find      'gfind find'
        xargs     'gxargs xargs'
        tar       'gtar tar'
        dircolors 'gdircolors dircolors'
        git       'git'
        ports     'lsof'
    )
    local -A linux_fallbacks=(
        ls        'eza ls'
        tree      'eza tree'
        vim       'nvim vim'
        vi        'nvim vi'
        sed       'sed'
        grep      'grep'
        find      'find'
        xargs     'xargs'
        tar       'tar'
        dircolors 'dircolors'
        git       'git'
        ports     'ss netstat'
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

    # eza needs an explicit flag to produce a tree. When the standalone tree
    # command wins the fallback selection it already has the requested name,
    # so leave it unaliased.
    if [[ ${selected[tree]:-} == eza ]]; then
        _dot_alias tree 'eza --tree'
    fi

    for command_name executable in "${(@kv)selected}"; do
        [[ $command_name == (ls|tree|dircolors|git|ports) ]] && continue
        [[ $command_name == $executable ]] && continue
        _dot_alias "$command_name" "$executable"
    done

    if (( $+commands[docker] )) && [[ -x ${commands[docker]} ]]; then
        _dot_alias dps 'docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}"'
        _dot_alias dpsa 'docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}"'
    fi

    if [[ ${selected[git]:-} == git ]]; then
        _dot_alias gss 'git status --short'
        _dot_alias glog 'git log --oneline --decorate -12'
        _dot_alias gd 'git diff'
        _dot_alias gds 'git diff --staged'
    fi

    case ${selected[ports]:-} in
        lsof|ss|netstat)
            typeset -g _DOT_ZSH_PORTS_COMMAND=${selected[ports]}
            typeset -g _DOT_ZSH_MANAGED_PORTS=1
            ports() {
                case "${_DOT_ZSH_PORTS_COMMAND}:${1:-all}" in
                    lsof:all) command lsof -nP -iTCP -sTCP:LISTEN -iUDP -FpcLutn | _dot_format_lsof_ports ;;
                    lsof:tcp) command lsof -nP -iTCP -sTCP:LISTEN -FpcLutn | _dot_format_lsof_ports ;;
                    lsof:udp) command lsof -nP -iUDP -FpcLutn | _dot_format_lsof_ports ;;
                    ss:all) command ss -ltnup ;;
                    ss:tcp) command ss -ltnp ;;
                    ss:udp) command ss -lnup ;;
                    netstat:all) command netstat -ltnup ;;
                    netstat:tcp) command netstat -ltnp ;;
                    netstat:udp) command netstat -lnup ;;
                    *) print -u2 -- 'usage: ports [all|tcp|udp]'; return 2 ;;
                esac
            }
            ;;
    esac

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
