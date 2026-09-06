#!/bin/bash

# This script contains functions that can be used anywhere during custom setup.

# Nothing here is POSIX sh: the functions below use `local`, $'...' and
# [[ ]]. Say so rather than failing in pieces further down.
if [ -z "${BASH_VERSION:-}" ] && [ -z "${ZSH_VERSION:-}" ]; then
    echo "unknow shell, neither bash nor zsh" >&2
fi

# The colours a log line can use are fixed, so the escapes are constants.
# They used to come from bash_color.sh and zsh_color.sh, a pair of vendored
# helpers that built the same handful of escapes from scratch on every call.
# Both emitted identical SGR codes, so one set of constants replaced both and
# let bash_log/zsh_log collapse into a single dlog().
_DOT_C_RESET=$'\033[0m'
_DOT_C_RED=$'\033[0;31m'
_DOT_C_GREEN=$'\033[0;32m'
_DOT_C_CYAN=$'\033[0;36m'
_DOT_C_LIGHTBLUE=$'\033[0;94m'
_DOT_C_ITALIC_CYAN=$'\033[3;36m'

# dlog <level> <message> [file]
# level is one of error, warn, info, debug; anything above $DOT_LOG_LEVEL is
# dropped. Example:
# dlog 'info' 'info hello'
# dlog 'debug' 'debug hello' '/apps/omz/omz-pre.sh'
#
# Not named log(): macOS ships /usr/bin/log for querying the unified logging
# system, and a function by that name shadows it in every interactive shell.
#
# Writes into _dlog_lvl rather than echoing, so that callers can read the
# result without a command substitution.
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

    # Decide whether this line is wanted before formatting it. At the default
    # level most calls are 'info' and get dropped, so everything below would
    # be thrown away.
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

    # Everything variable goes through an argument rather than the format
    # string, so that a '%' in a message or path cannot corrupt the output.
    printf '%s: %s%-36s%s%s\n' "$head" "$c" "$msg" "$_DOT_C_RESET" "$file"
}

# install.sh runs each app installer as a separate process; without this they
# would lose dlog and have to source this file again. The escapes have to go
# too, or an exported dlog() prints its levels uncoloured.
if [ -n "${BASH_VERSION:-}" ]; then
    export -f dlog _dlog_level
    export _DOT_C_RESET _DOT_C_RED _DOT_C_GREEN _DOT_C_CYAN \
           _DOT_C_LIGHTBLUE _DOT_C_ITALIC_CYAN
fi

# A wrapper of dlog 'info'
info() {
    dlog 'info' "$1" "${2:-}"
}

# A wrapper of dlog 'warn'
warn() {
    dlog 'warn' "$1" "${2:-}"
}

# A wrapper of dlog 'error'
error() {
    dlog 'error' "$1" "${2:-}"
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

# Get curent relative file path to another dir
# Usage:
# cur_path_relative "/home" "$0"
#
# Every caller is a log line in a config file that zshrc sources, passing its
# own $0, so this runs about twenty times per shell startup. It used to go
# through abs_path twice, which meant four dirname/basename processes plus a
# cd/pwd subshell each -- roughly 40ms a call. Prefix stripping needs none of
# that: $0 is already absolute here because every source site spells out a
# full path, and the $PWD branch covers anyone who does not.
cur_path_relative() {
    local base="${1%/}"
    local cur="$2"

    case "$cur" in
        /*) ;;
        *) cur="$PWD/$cur";;
    esac

    case "$cur" in
        "$base"/*) printf '%s\n' "${cur#"$base"}";;
        # Not under $base, so there is no relative form to give; the absolute
        # path is still the most useful thing to put in the log.
        *) printf '%s\n' "$cur";;
    esac
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
