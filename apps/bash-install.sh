#!/bin/bash

set -euo pipefail

# DOT_DIR, APP_DIR and DOT_LOG_LEVEL are exported by install.sh.
source "$DOT_DIR/apps/shell/install.sh"

info "Installing bash configuration"

BASH_APP_DIR=$(abs_path "$APP_DIR/bash")

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

install_bash_completion() {
    if [ -r /usr/share/bash-completion/bash_completion ] ||
       [ -r /etc/bash_completion ] ||
       [ -r /opt/homebrew/etc/profile.d/bash_completion.sh ] ||
       [ -r /usr/local/etc/profile.d/bash_completion.sh ]; then
        info "already installed" "bash-completion"
        return 0
    fi

    info "Installing bash-completion"
    if command_exist brew; then
        brew install bash-completion
    elif command_exist apt-get; then
        run_privileged apt-get install -y bash-completion
    elif command_exist dnf; then
        run_privileged dnf install -y bash-completion
    elif command_exist pacman; then
        run_privileged pacman -S --needed --noconfirm bash-completion
    elif command_exist apk; then
        run_privileged apk add bash-completion
    else
        warn "no supported package manager; continuing without bash-completion"
        return 0
    fi
}

# Completion is optional so a minimal server still receives a usable shell.
install_bash_completion || warn "continuing without bash-completion"

link_config "$BASH_APP_DIR/bashrc" "$HOME/.bashrc"
link_config "$BASH_APP_DIR/bash_profile" "$HOME/.bash_profile"

info "Finished"
