#!/bin/bash

set -euo pipefail

# DOT_DIR is exported by parent script
# APP_DIR is exported by parent script
# DOT_LOG_LEVEL is exported by parent script
source "$DOT_DIR/apps/zsh/lib.sh"

info "Installing zsh configuration"

ZSH_APP_DIR=$(abs_path "$APP_DIR/zsh")
ZSH_CONF_FILE="$ZSH_APP_DIR/zshrc"

# Plugins live under XDG data. Keep this in step with DOT_ZSH_PLUGIN_DIR in
# zshrc.
PLUGIN_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
mkdir -p "$PLUGIN_DIR"

link_config "$ZSH_CONF_FILE" "$HOME/.zshrc"

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

install_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
install_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git

install_plugin powerlevel10k https://github.com/romkatv/powerlevel10k.git

# p10k talks to gitstatusd, a per-platform binary it fetches on first use.
# Doing it here instead means the first new shell is not held up by a
# download, and that a machine which cannot reach GitHub finds out now rather
# than by printing an error on every startup. Failure is not fatal: p10k falls
# back to zsh's own vcs_info, and such a host should set
# POWERLEVEL9K_DISABLE_GITSTATUS=1 in host-conf to silence the warning.
GITSTATUS_INSTALL="$PLUGIN_DIR/powerlevel10k/gitstatus/install"
if [ -x "$GITSTATUS_INSTALL" ]; then
    info "Fetching gitstatusd"
    if ! sh "$GITSTATUS_INSTALL" -f; then
        warn "gitstatusd unavailable; set POWERLEVEL9K_DISABLE_GITSTATUS=1 on this host"
    fi
fi

info "Finished"
