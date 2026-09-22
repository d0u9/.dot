#!/bin/bash

# Shared Bash/Zsh interactive helpers.
if [ -z "${BASH_VERSION:-}" ] && [ -z "${ZSH_VERSION:-}" ]; then
    echo "unknown shell, neither bash nor zsh" >&2
fi

_DOT_C_RESET=$'\033[0m'
_DOT_C_RED=$'\033[0;31m'
_DOT_C_GREEN=$'\033[0;32m'
_DOT_C_CYAN=$'\033[0;36m'
_DOT_C_LIGHTBLUE=$'\033[0;94m'
_DOT_C_ITALIC_CYAN=$'\033[3;36m'

_dlog_level() {
    case "$1" in
        'error') _dlog_lvl=1;;
        'warn')  _dlog_lvl=2;;
        'info')  _dlog_lvl=3;;
        'debug') _dlog_lvl=4;;
        *)       _dlog_lvl=2;;
    esac
}

dlog() {
    local level="$1"
    local msg="$2"
    local file="${3:-}"
    local _dlog_lvl threshold

    _dlog_level "${DOT_LOG_LEVEL:-info}"
    threshold=$_dlog_lvl
    _dlog_level "$level"
    [ "$_dlog_lvl" -le "$threshold" ] || return 0

    local head c
    case "$level" in
        'debug') head="${_DOT_C_GREEN}[D]${_DOT_C_RESET}"; c="$_DOT_C_LIGHTBLUE";;
        'info')  head="${_DOT_C_GREEN}[I]${_DOT_C_RESET}"; c="$_DOT_C_CYAN";;
        'warn')  head="${_DOT_C_GREEN}[W]${_DOT_C_RESET}"; c="$_DOT_C_CYAN";;
        'error') head="${_DOT_C_RED}[E]${_DOT_C_RESET}";   c="$_DOT_C_CYAN";;
        *)       head="${_DOT_C_GREEN}[?]${_DOT_C_RESET}"; c="$_DOT_C_RESET";;
    esac

    if [ -n "$file" ]; then
        file="[${_DOT_C_ITALIC_CYAN}${file}${_DOT_C_RESET}]"
    fi
    printf '%s: %s%-36s%s%s\n' "$head" "$c" "$msg" "$_DOT_C_RESET" "$file"
}

if [ -n "${BASH_VERSION:-}" ]; then
    export -f dlog _dlog_level
    export _DOT_C_RESET _DOT_C_RED _DOT_C_GREEN _DOT_C_CYAN \
           _DOT_C_LIGHTBLUE _DOT_C_ITALIC_CYAN
fi

debug() { dlog 'debug' "$1" "${2:-}"; }
info() { dlog 'info' "$1" "${2:-}"; }
warn() { dlog 'warn' "$1" "${2:-}"; }
error() { dlog 'error' "$1" "${2:-}"; }

command_exist() {
    command -v "$1" &> /dev/null
}

# Prepend an existing directory once. Keep PATH exported for child processes.
_dot_prepend_path_if_dir() {
    local dir="$1"
    [ -d "$dir" ] || return 0
    case :$PATH: in
        *:"$dir":*) ;;
        *) PATH="$dir:$PATH";;
    esac
    export PATH
}
