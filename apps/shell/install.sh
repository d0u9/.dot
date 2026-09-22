#!/bin/bash

# Shared installer helpers. $DOT_DIR is exported by install.sh.
source "$DOT_DIR/apps/shell/lib.sh"

abs_path() {
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

cur_path_relative() {
    local base="${1%/}"
    local cur="$2"
    case "$cur" in
        /*) ;;
        *) cur="$PWD/$cur";;
    esac
    case "$cur" in
        "$base"/*) printf '%s\n' "${cur#"$base"}";;
        *) printf '%s\n' "$cur";;
    esac
}

yes_or_no() {
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

back_or_override() {
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
    if ! ln -sfn "$src" "$tgt"; then
        error "failed to link $tgt -> $src"
        return 1
    fi
    info "linked -> $src" "$tgt"
}
