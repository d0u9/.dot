#!/bin/bash

# This script contains functions that can be used anywhere during custom setup.

# Callers that do not set DOT_OMZ_DIR (the installers run straight from a
# clone) still need the colour helpers that sit next to this file.
if [ -z "${DOT_OMZ_DIR:-}" ] && [ -n "${BASH_SOURCE:-}" ]; then
    DOT_OMZ_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
fi

if [ -n "${BASH_VERSION:-}" ]; then
    source "$DOT_OMZ_DIR/bash_color.sh"
    function log() {
        bash_log "$@"
    }
    export -f log
elif [ -n "${ZSH_VERSION:-}" ]; then
    source "$DOT_OMZ_DIR/zsh_color.sh"
    function log() {
        zsh_log "$@"
    }
else
    echo "unknow shell, neither bash nor zsh"
fi

# log [level=info] [message] <file>
# Example:
# log 'info' 'info hello'
# log 'debug' 'debug hello'
bash_log() {
    level_to_num() {
        case "$1" in
            'error') echo 1;;
            'warn') echo 2;;
            'info') echo 3;;
            'debug') echo 4;;
            *) echo 2;
        esac
    }

    local level="$1"
    local msg="$2"
    local file="${3:-}"
    local head_str=""
    local msg_str=""
    case "$level" in
        'debug')
            msg_str=$(clr_blue "$msg")
            head_str="$(clr_green [D])"
            ;;
        'info')
            msg_str=$(clr_blue "$msg")
            head_str="$(clr_green [I])"
            ;;
        'warn')
            msg_str=$(clr_blue "$msg")
            head_str="$(clr_green [W])"
            ;;
        'error')
            msg_str=$(clr_blue "$msg")
            head_str="$(clr_red [E])"
            ;;
        *) ;;
    esac

    if [ ! -z "$file" ]; then
        file="[$(clr_cyan)$file$(clr_reset)]"
    fi

    tl=$(level_to_num "${DOT_LOG_LEVEL:-info}")
    l=$(level_to_num "$level")
    if [ "$l" -le "$tl" ]; then
        printf "$head_str: %-36s$file\n" "$msg_str"
    fi
}

# log [level=info] [message] <file>
# Example:
# log 'info' 'info hello'
# log 'debug' 'debug hello'
zsh_log() {
    level_to_num() {
        case "$1" in
            'error') echo 1;;
            'warn') echo 2;;
            'info') echo 3;;
            'debug') echo 4;;
            *) echo 2;
        esac
    }

    local level="$1"
    local msg="$2"
    local file="${3:-}"
    local c_reset="$(color reset)"
    local head_str=""
    case "$level" in
        'debug')
            c=$(color lightblue)
            head_str="$(color green)[D]$(color reset)"
            ;;
        'info')
            c=$(color cyan)
            head_str="$(color green)[I]$(color reset)"
            ;;
        'warn')
            c=$(color cyan)
            head_str="$(color green)[W]$(color reset)"
            ;;
        'error')
            c=$(color cyan)
            head_str="$(color red)[E]$(color reset)"
            ;;
        *) c="$c_reset";;
    esac

    if [ ! -z "$file" ]; then
        file="[$(color -i cyan)$file$(color reset)]"
    fi

    tl=$(level_to_num "${DOT_LOG_LEVEL:-info}")
    l=$(level_to_num "$level")
    if [ "$l" -le "$tl" ]; then
        printf "$head_str: $c%-36s$c_reset$file\n" "$msg"
    fi
}

# A wrapper of log 'info'
info() {
    log 'info' "$1" "${2:-}"
}

# A wrapper of log 'info'
warn() {
    log 'warn' "$1" "${2:-}"
}

# A wrapper of log 'error'
error() {
    log 'error' "$1" "${2:-}"
}

# Test if command is exist
# command_exist "command_name"
command_exist() {
    command -v "$1" &> /dev/null
}

# Turn a path into an absolute one without resolving the last component, so it
# works on paths that do not exist yet. Only the parent directory has to be
# real. This is what we used to need GNU realpath for; doing it with cd/pwd
# keeps the scripts working on a machine without brew and coreutils.
# Usage:
# abs_path "$HOME/.config/nvim"
abs_path() {
    # Not named `path`: in zsh that name is tied to $PATH.
    local target="$1"
    local dir base
    case "$target" in
        /) echo "/"; return 0;;
    esac
    dir=$(dirname -- "$target")
    base=$(basename -- "$target")
    dir=$(cd -- "$dir" 2> /dev/null && pwd -P) || return 1
    case "$dir" in
        /) echo "/$base";;
        *) echo "$dir/$base";;
    esac
}

# Get Current file path
# Usage:
# cur_path "$0"
cur_path() {
    echo "$(dirname -- "$1")/$(basename -- "$1")"
}

# Get curent relative file path to another dir
# Usage:
# cur_path_relative "/home" "$0"
cur_path_relative() {
    local base cur
    base=$(abs_path "$1")
    cur=$(abs_path "$(cur_path "$2")")
    echo "${cur#"$base"}"
}

# Prmote "YES" or "NO" for choice
# $1: hint message
yes_or_no()
{
    while true; do
        read -p "$1 ([y]/n)?" -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]] || [ -z "$REPLY" ]; then
            return 0
        elif [[ $REPLY =~ ^[Nn]$ ]]; then
            return 1
        else
            echo "Please entry Y, y or N, n"
        fi
    done
}

# Move whatever sits at $1 out of the way, asking before touching anything the
# user may care about. A symlink is assumed to be ours from an earlier install
# and is dropped without asking.
# $1: file to test
# Returns 1 when the path could not be cleared.
back_or_override()
{
    local file="$1"
    if [ -L "$file" ]; then
        rm -f "$file"
        return 0
    fi
    [ -e "$file" ] || return 0

    if ! yes_or_no "$file exists, back it up"; then
        rm -fr "$file"
        return 0
    fi
    if [ -e "$file.bk" ]; then
        if ! yes_or_no "$file.bk exists, override it"; then
            error "Can't backup $file, skipped"
            return 1
        fi
        rm -fr "$file.bk"
    fi
    mv "$file" "$file.bk"
}

# Point $2 at $1, backing up whatever is in the way first. Every app installer
# goes through here so that a re-run is a no-op instead of a silent failure.
# $1: source path inside this repo
# $2: link to create
link_config() {
    local src="$1"
    local tgt="$2"

    if [ ! -e "$src" ]; then
        error "link source does not exist: $src"
        return 1
    fi

    if [ -L "$tgt" ] && [ "$(readlink "$tgt")" = "$src" ]; then
        info "already linked" "$tgt"
        return 0
    fi

    back_or_override "$tgt" || return 1
    mkdir -p "$(dirname -- "$tgt")" || return 1
    # -n keeps ln from descending into $tgt when it is a symlink to a directory
    if ! ln -sfn "$src" "$tgt"; then
        error "failed to link $tgt -> $src"
        return 1
    fi
    info "linked -> $src" "$tgt"
}
