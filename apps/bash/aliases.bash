# Interactive command replacements. Keep fallback order aligned with Zsh.
# This uses indexed arrays only, so it works in macOS's Bash 3.2.

_dot_bash_aliases() {
    local command_name executable executable_path
    local ls_cmd long_flags all_flags

    # Re-sourcing must remove aliases whose replacement disappeared.
    if [ -n "${_DOT_BASH_MANAGED_ALIASES+x}" ]; then
        for command_name in "${_DOT_BASH_MANAGED_ALIASES[@]}"; do
            unalias "$command_name" 2>/dev/null
        done
    fi
    _DOT_BASH_MANAGED_ALIASES=()
    if [ -n "${_DOT_BASH_MANAGED_PORTS+x}" ]; then
        unset -f ports 2>/dev/null
        unset _DOT_BASH_MANAGED_PORTS _DOT_BASH_PORTS_COMMAND
    fi

    _dot_bash_alias() {
        alias "$1=$2"
        _DOT_BASH_MANAGED_ALIASES+=("$1")
    }

    # Set $selected to first executable candidate. `type -P` bypasses aliases
    # and functions; test path too because Bash can retain stale hash entries.
    _dot_bash_select() {
        selected=
        for executable in "${@:2}"; do
            executable_path=$(type -P "$executable" 2>/dev/null) || continue
            [ -x "$executable_path" ] || continue
            selected=$executable
            return 0
        done
        return 1
    }

    case $OSTYPE in
        darwin*)
            _dot_bash_select ls eza gls ls; local selected_ls=$selected
            _dot_bash_select tree eza tree; local selected_tree=$selected
            _dot_bash_select vim nvim vim; local selected_vim=$selected
            _dot_bash_select vi nvim vi; local selected_vi=$selected
            _dot_bash_select sed gsed sed; local selected_sed=$selected
            _dot_bash_select grep ggrep grep; local selected_grep=$selected
            _dot_bash_select find gfind find; local selected_find=$selected
            _dot_bash_select xargs gxargs xargs; local selected_xargs=$selected
            _dot_bash_select tar gtar tar; local selected_tar=$selected
            _dot_bash_select dircolors gdircolors dircolors; local selected_dircolors=$selected
            _dot_bash_select ports lsof; local selected_ports=$selected
            ;;
        linux*)
            _dot_bash_select ls eza ls; local selected_ls=$selected
            _dot_bash_select tree eza tree; local selected_tree=$selected
            _dot_bash_select vim nvim vim; local selected_vim=$selected
            _dot_bash_select vi nvim vi; local selected_vi=$selected
            _dot_bash_select sed sed; local selected_sed=$selected
            _dot_bash_select grep grep; local selected_grep=$selected
            _dot_bash_select find find; local selected_find=$selected
            _dot_bash_select xargs xargs; local selected_xargs=$selected
            _dot_bash_select tar tar; local selected_tar=$selected
            _dot_bash_select dircolors dircolors; local selected_dircolors=$selected
            _dot_bash_select ports ss netstat; local selected_ports=$selected
            ;;
        *)
            _dot_bash_select ls ls; local selected_ls=$selected
            local selected_tree= selected_vim= selected_vi= selected_sed=
            local selected_grep= selected_find= selected_xargs= selected_tar=
            local selected_dircolors= selected_ports=
            ;;
    esac
    _dot_bash_select git git; local selected_git=$selected

    long_flags=-lh
    all_flags=-lah
    case $selected_ls in
        eza)
            ls_cmd='eza --color=auto --group-directories-first'
            long_flags=-l
            all_flags=-la
            ;;
        gls) ls_cmd='gls --color=auto --group-directories-first' ;;
        ls)
            case $OSTYPE in
                darwin*) export CLICOLOR=1; ls_cmd='ls -G' ;;
                linux*) ls_cmd='ls --color=auto' ;;
                *) ls_cmd=ls ;;
            esac
            ;;
    esac
    if [ -n "$ls_cmd" ]; then
        _dot_bash_alias ls "$ls_cmd"
        _dot_bash_alias l "$ls_cmd -1"
        _dot_bash_alias ll "$ls_cmd $long_flags"
        _dot_bash_alias la "$ls_cmd $all_flags"
    fi

    [ "$selected_tree" = eza ] && _dot_bash_alias tree 'eza --tree'

    for command_name in vim vi sed grep find xargs tar; do
        case $command_name in
            vim) executable=$selected_vim ;;
            vi) executable=$selected_vi ;;
            sed) executable=$selected_sed ;;
            grep) executable=$selected_grep ;;
            find) executable=$selected_find ;;
            xargs) executable=$selected_xargs ;;
            tar) executable=$selected_tar ;;
        esac
        [ -n "$executable" ] && [ "$command_name" != "$executable" ] &&
            _dot_bash_alias "$command_name" "$executable"
    done

    _dot_bash_alias .. 'cd ..'
    _dot_bash_alias ... 'cd ../..'

    if [ "$selected_git" = git ]; then
        _dot_bash_alias gss 'git status --short'
        _dot_bash_alias glog 'git log --oneline --decorate -12'
        _dot_bash_alias gd 'git diff'
        _dot_bash_alias gds 'git diff --staged'
    fi

    case $selected_ports in
        lsof|ss|netstat)
            _DOT_BASH_PORTS_COMMAND=$selected_ports
            _DOT_BASH_MANAGED_PORTS=1
            ports() {
                case "${_DOT_BASH_PORTS_COMMAND}:${1:-all}" in
                    lsof:all) command lsof -nP -iTCP -sTCP:LISTEN -iUDP -FpcLutn | _dot_format_lsof_ports ;;
                    lsof:tcp) command lsof -nP -iTCP -sTCP:LISTEN -FpcLutn | _dot_format_lsof_ports ;;
                    lsof:udp) command lsof -nP -iUDP -FpcLutn | _dot_format_lsof_ports ;;
                    ss:all) command ss -ltnup ;;
                    ss:tcp) command ss -ltnp ;;
                    ss:udp) command ss -lnup ;;
                    netstat:all) command netstat -ltnup ;;
                    netstat:tcp) command netstat -ltnp ;;
                    netstat:udp) command netstat -lnup ;;
                    *) printf 'usage: ports [all|tcp|udp]\n' >&2; return 2 ;;
                esac
            }
            ;;
    esac

    if executable_path=$(type -P docker 2>/dev/null) && [ -x "$executable_path" ]; then
        _dot_bash_alias dps 'docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}"'
        _dot_bash_alias dpsa 'docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}"'
    fi

    # Match Zsh's GNU-colour setup, but Bash has no shared generated-init cache.
    if [ -n "$selected_dircolors" ]; then
        local dircolors_init
        dircolors_init=$("$selected_dircolors" -b 2>/dev/null) && eval "$dircolors_init"
    fi

    unset -f _dot_bash_alias _dot_bash_select
}

_dot_bash_aliases
unset -f _dot_bash_aliases
