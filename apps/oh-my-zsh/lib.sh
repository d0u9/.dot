#!/bin/bash

# This script contains functions that can be used anywhere during custom setup.

if [ "$BASH_VERSION" ]; then
    source $HOME/.dot/apps/oh-my-zsh/bash_color.sh
    function log() {
        bash_log "$@"
    }
    export log
elif [ "$ZSH_VERSION" ]; then
    source $HOME/.dot/apps/oh-my-zsh/zsh_color.sh
    function log() {
        zsh_log "$@"
    }
    export log
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
    local file="$3"
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

    tl=$(level_to_num "$DOT_LOG_LEVEL")
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
    local file="$3"
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

    tl=$(level_to_num "$DOT_LOG_LEVEL")
    l=$(level_to_num "$level")
    if [ "$l" -le "$tl" ]; then
        printf "$head_str: $c%-36s$c_reset$file\n" "$msg"
    fi
}

# A wrapper of log 'info'
info() {
    log 'info' "$1" "$2"
}

# A wrapper of log 'info'
warn() {
    log 'warn' "$1" "$2"
}

# A wrapper of log 'error'
error() {
    log 'error' "$1" "$2"
}

# Test if command is exist
# command_exist "command_name"
command_exist() {
    command -v "$1" &> /dev/null
}

prealpath() {
    echo "xx"
}

# find and make realpath a GNU realpath
# For macos on which `grealpath` is installed, this function will alias `grealpath` as `realpath`
set_gnu_realpath() {
    local test_path="/tmp/././this_is_a_long_invalid_path_for_tesing"
    realpath "$test_path" &> /dev/null && return 0
    if command_exist "grealpath" && grealpath "$test_path" &> /dev/null; then
        realpath() {
            grealpath "$@"
        }
        warn "Export grealpath as realpath"
        export -f realpath

        return 0
    fi
    return 1
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
    base=$(realpath "$1")
    cur=$(realpath $(cur_path "$2"))
    echo ${cur#"$base"}
}

# Prmote "YES" or "NO" for choice
# $1: hint message
yes_or_no()
{
    while true; do
        read -p "$1 ([y]/n)?" -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            return 0
        elif [[ $REPLY =~ ^[Nn]$ ]]; then
            return 1
        else
            echo "Please entry Y, y or N, n"
        fi
    done
}

# $1: file to test
back_or_override()
{
    FILE=$1
    if [ -e $FILE ]; then
        yes_or_no "$FILE file exist, backup it"
        if [ $? -eq "0" ]; then
            if [ -e $FILE.bk ]; then
                yes_or_no "$FILE.bk exist, override it?"
                if [ $? -eq "1" ]; then
                    echo "Can't backup $FILE, abort!"
                    exit 1
                fi
                rm -fr $FILE.bk
            fi
            mv $FILE $FILE.bk
        else
            rm -fr $FILE
        fi
    fi
}
