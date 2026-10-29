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
        unset -f ports killport 2>/dev/null
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
    local selected_tar= selected_dircolors= selected_git= selected_gitdiff=
    local selected_ports= selected_aria2c= selected_editor= editor_candidates= git_diff git_difftool aria2
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
        [ "$row_command" = editor ] && editor_candidates=$candidates
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

    # eza-only views. Without eza, each name prints how to get it.
    for command_name in lss lsc lsl; do
        case $command_name in
            lss) executable='eza -lh --total-size --sort=size -r' ;;
            lsc) executable='eza --code' ;;
            lsl) executable='eza -lah --hyperlink' ;;
        esac
        [ "$selected_ls" = eza ] ||
            executable="echo '$command_name: needs eza (install.sh eza)' >&2; false #"
        _dot_bash_alias "$command_name" "$executable"
    done

    # aria2 downloads: resumable, 16 connections per file; dll reads a URL
    # list file, dl1 uses one connection, dlt stops seeding when complete.
    aria2='aria2c -c --file-allocation=none'
    for command_name in dl dll dl1 dlt; do
        case $command_name in
            dl) executable="$aria2 -x16 -s16 -k1M" ;;
            dll) executable="$aria2 -x16 -s16 -k1M -i" ;;
            dl1) executable=$aria2 ;;
            dlt) executable="$aria2 --seed-time=0" ;;
        esac
        [ "$selected_aria2c" = aria2c ] ||
            executable="echo '$command_name: needs aria2 (install.sh aria2)' >&2; false #"
        _dot_bash_alias "$command_name" "$executable"
    done

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

    # Programs such as git, crontab and zellij's scrollback editor read these.
    # Keep a value only when it names a candidate from the table that ranks at
    # least as high as the one selected: a distribution default such as vim
    # gives way to nvim, and an editor the table does not list, such as emacs
    # or nano, is replaced too.
    if [ -n "$selected_editor" ]; then
        local var current current_path candidate rank rank_current rank_selected
        for var in EDITOR VISUAL; do
            current_path=${!var%% *}
            current=${current_path##*/}
            case $current_path in */*) ;; *) current_path=$(type -P "$current_path" 2>/dev/null) || current_path= ;; esac
            rank=0 rank_current=0 rank_selected=0
            # An empty or unlisted value keeps rank 0 and always loses.
            for candidate in $editor_candidates; do
                rank=$((rank + 1))
                [ "$candidate" = "$current" ] && rank_current=$rank
                [ "$candidate" = "$selected_editor" ] && rank_selected=$rank
            done
            if [ ! -x "$current_path" ] || [ "$rank_current" -eq 0 ] || [ "$rank_current" -gt "$rank_selected" ]; then
                export "$var=$selected_editor"
            fi
        done
    fi

    _dot_bash_alias .. 'cd ..'
    _dot_bash_alias ... 'cd ../..'

    if [ "$selected_git" = git ]; then
        _dot_bash_alias g 'git'
        _dot_bash_alias gst 'git status'
        _dot_bash_alias ga 'git add'
        _dot_bash_alias gc 'git commit'
        _dot_bash_alias gf 'git fetch'
        _dot_bash_alias gsw 'git switch'
        _dot_bash_alias gswc 'git switch -c'
        _dot_bash_alias gb 'git branch -vv'
        git_diff='git diff'
        [ "$selected_gitdiff" = difft ] && git_diff='DFT_DISPLAY=side-by-side-show-both GIT_EXTERNAL_DIFF=difft git diff'
        _dot_bash_alias gss 'git status --short'
        _dot_bash_alias glog 'git log --oneline --decorate -12'
        _dot_bash_alias glg 'git log --graph --all --decorate --color=auto --format="%C(auto)%h%d %s %C(dim)(%ar, %an)%C(reset)"'
        _dot_bash_alias gd "$git_diff"
        _dot_bash_alias gds "$git_diff --staged"
        # nvimdiff views; pass a range such as HEAD^! to view one commit.
        git_difftool='git difftool -y --trust-exit-code -t nvimdiff'
        [ "$selected_vim" = nvim ] ||
            git_difftool="echo 'gdv: needs nvim (install.sh nvim)' >&2; false #"
        _dot_bash_alias gdv "$git_difftool"
        _dot_bash_alias gdvs "$git_difftool --staged"
    fi

    case $selected_ports in
        lsof|ss|netstat)
            _DOT_BASH_PORTS_COMMAND=$selected_ports
            _DOT_BASH_MANAGED_PORTS=1
            # Options and output are documented at _dot_ports and _dot_killport
            # in apps/shell/lib.sh.
            ports() { _dot_ports "$_DOT_BASH_PORTS_COMMAND" "$@"; }
            killport() { _dot_killport "$_DOT_BASH_PORTS_COMMAND" "$@"; }
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
