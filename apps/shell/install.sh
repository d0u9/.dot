#!/bin/bash

# Shared installer helpers. $DOT_DIR is exported by install.sh.
source "$DOT_DIR/apps/shell/lib.sh"

# QUESTION [DEFAULT]: without a terminal, answer DEFAULT (y unless n).
yes_or_no() {
    if [ ! -t 0 ]; then [ "${2:-y}" = y ]; return; fi
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
        if ! yes_or_no "$file.bk exists, override it" n; then
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
    if ! ln -sfn "$src" "$tgt"; then
        error "failed to link $tgt -> $src"
        return 1
    fi
    info "linked -> $src" "$tgt"
}

# Run a system package manager as root when it requires that. Homebrew is
# deliberately handled outside this helper and must never run through sudo.
run_privileged() {
    if [ "$EUID" -eq 0 ]; then
        "$@"
    elif command_exist sudo; then
        sudo "$@"
    else
        error "sudo is required to run $1"
        return 1
    fi
}

# Install PACKAGE with the first supported package manager.
pkg_install() {
    info "Installing $1"
    if command_exist brew; then brew install "$1"
    elif command_exist apt-get; then run_privileged apt-get install -y "$1"
    elif command_exist dnf; then run_privileged dnf install -y "$1"
    elif command_exist pacman; then run_privileged pacman -S --needed --noconfirm "$1"
    elif command_exist apk; then run_privileged apk add "$1"
    else error "no supported package manager for $1"; return 1
    fi
}
