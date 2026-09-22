# Interactive command replacements. Keep fallback order aligned with Zsh.
# This uses indexed arrays only, so it works in macOS's Bash 3.2.

_dot_bash_aliases() {
    local command_name executable executable_path selected
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

    # Set $selected to the first installed candidate. `type -P` bypasses
    # aliases and functions; test the path too because Bash can retain stale
    # hash entries after an uninstall.
    _dot_bash_select() {
        selected=
        for executable in "$@"; do
            executable_path=$(type -P "$executable" 2>/dev/null) || continue
            [ -x "$executable_path" ] || continue
            selected=$executable
            return 0
        done
        return 1
    }

    # The candidate table is apps/shell/fallbacks, shared with Zsh so the two
    # shells cannot drift apart. `while read` from a file forks nothing.
    #
    # Only the column choice is per-shell, because each shell has to know
    # which one applies to it. The candidates themselves, and the decision to
    # keep the macOS and Linux columns separate, live in that file.
    #
    # Bash 3.2 on macOS has no associative arrays, so each row's winner lands
    # in selected_<command> through `printf -v`. Declaring them here keeps
    # them function-local; `printf -v` would otherwise create globals.
    local selected_ls= selected_tree= selected_vim= selected_vi=
    local selected_sed= selected_grep= selected_find= selected_xargs=
    local selected_tar= selected_dircolors= selected_git= selected_ports=
    local row_command row_macos row_linux candidates
    while IFS='|' read -r row_command row_macos row_linux; do
        row_command=${row_command// }
        case $row_command in ''|\#*) continue;; esac
        case $OSTYPE in
            darwin*) candidates=$row_macos ;;
            linux*)  candidates=$row_linux ;;
            # An unknown platform maps each command to itself, so the
            # selection finds the platform default and aliases nothing.
            *)       candidates=$row_command ;;
        esac
        # Unquoted on purpose: the field holds space-separated candidates.
        if _dot_bash_select $candidates; then
            printf -v "selected_$row_command" %s "$selected"
        fi
    done < "$DOT_BASH_DIR/../shell/fallbacks"

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
            # The colour flag depends on whether this ls is BSD's or GNU's,
            # which the platform stands in for. A probe would cost a fork.
            case $OSTYPE in
                darwin*) export CLICOLOR=1; ls_cmd='ls -G' ;;
                linux*) ls_cmd='ls --color=auto' ;;
                *) ls_cmd=ls ;;
            esac
            ;;
        # A newly listed implementation gets standard flags by default; add a
        # preset above if it needs its own. Matches core/aliases.zsh, which
        # had this branch while this file did not, so a new table row went
        # unaliased here.
        *) ls_cmd=$selected_ls ;;
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
