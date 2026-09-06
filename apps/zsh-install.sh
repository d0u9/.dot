#!/bin/bash

set -euo pipefail

# DOT_DIR is exported by parent script
# APP_DIR is exported by parent script
# DOT_LOG_LEVEL is exported by parent script
source "$DOT_DIR/apps/zsh/lib.sh"

info "Installing zsh configuration"

ZSH_APP_DIR=$(abs_path "$APP_DIR/zsh")
ZSH_CONF_FILE="$ZSH_APP_DIR/zshrc"

# Zsh plugins live under XDG data. Keep this in step with DOT_ZSH_PLUGIN_DIR
# in zshrc.
PLUGIN_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
mkdir -p "$PLUGIN_DIR"

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

# $1: command name, $2: package name
install_tool() {
    local command_name="$1"
    local package_name="$2"

    if command_exist "$command_name"; then
        info "already installed" "$command_name"
        return 0
    fi

    info "Installing $package_name"
    if command_exist brew; then
        brew install "$package_name"
    elif command_exist apt-get; then
        run_privileged apt-get install -y "$package_name"
    elif command_exist dnf; then
        run_privileged dnf install -y "$package_name"
    elif command_exist pacman; then
        run_privileged pacman -S --needed --noconfirm "$package_name"
    elif command_exist apk; then
        run_privileged apk add "$package_name"
    else
        error "no supported package manager for $package_name"
        return 1
    fi

    if ! command_exist "$command_name"; then
        error "$command_name is still unavailable after installing $package_name"
        return 1
    fi
}

install_tool fzf fzf
install_tool zoxide zoxide

# $1: name, $2: repo url
install_plugin() {
    local name="$1"
    local url="$2"
    local dir="$PLUGIN_DIR/$name"

    info "Installing $name"
    if [ -d "$dir/.git" ]; then
        # Pulling only helps when the checkout came from the same place. A
        # url that has moved -- switching off a fork, say -- would otherwise
        # keep fetching from the old remote forever, and the install would
        # report success while changing nothing.
        if [ "$(git -C "$dir" remote get-url origin 2>/dev/null)" != "$url" ]; then
            warn "remote differs, re-cloning" "$dir"
            rm -fr "$dir"
            git clone --depth=1 "$url" "$dir"
        else
            git -C "$dir" pull --ff-only
        fi
    else
        rm -fr "$dir"
        git clone --depth=1 "$url" "$dir"
    fi
}

install_plugin powerlevel10k https://github.com/romkatv/powerlevel10k.git
install_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
install_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git

link_config "$ZSH_CONF_FILE" "$HOME/.zshrc"

info "Finished"
