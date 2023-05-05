#!/bin/bash

# This script contains functions that can be used anywhere during custom setup.

# Ref: https://gist.github.com/nekwebdev/5971808
source $HOME/.dot/oh-my-zsh/color.sh

# log [level=info] [message] <file>
# Example:
# log 'info' 'info hello'
# log 'debug' 'debug hello'
log() {
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

# Get Current file path
# Usage:
# cur_path "$0"
cur_path() {
    print "$(dirname -- "$1")/$(basename -- "$1")"
}

# Get curent relative file path to another dir
# Usage:
# cur_path_relative "/home" "$0"
cur_path_relative() {
    base=$(realpath "$1")
    cur=$(realpath $(cur_path "$2"))
    echo ${cur#"$base"}
}
