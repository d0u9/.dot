#!/bin/bash

set -euo pipefail

# DOT_DIR is exported by parent script
# APP_DIR is exported by parent script
# DOT_LOG_LEVEL is exported by parent script
source "$DOT_DIR/apps/omz/lib.sh"

info "Installing oh-my-zsh configurations"

OMZ_APP_DIR=$(abs_path "$APP_DIR/omz")
OMZ_CONF_FILE="$OMZ_APP_DIR/zshrc"
OMZ_THEME_DIR="$OMZ_APP_DIR/themes"

# Everything below writes inside oh-my-zsh's own tree, so refuse to run rather
# than scatter themes and plugins across $HOME.
OMZ_HOME="${ZSH:-$HOME/.oh-my-zsh}"
if [ ! -d "$OMZ_HOME" ]; then
    error "oh-my-zsh not found at $OMZ_HOME; install it first"
    error "see https://github.com/ohmyzsh/ohmyzsh#basic-installation"
    exit 1
fi
OMZ_CUSTOM="${ZSH_CUSTOM:-$OMZ_HOME/custom}"

link_config "$OMZ_CONF_FILE" "$HOME/.zshrc"

info "Installing themes"
# Drop the dead links a previous install left behind, then relink.
find "$OMZ_HOME/themes" -maxdepth 1 -type l ! -exec test -e {} \; -delete

for file in "$OMZ_THEME_DIR"/*.zsh-theme; do
    [ -f "$file" ] || continue
    link_config "$file" "$OMZ_HOME/themes/$(basename "$file")"
done

# $1: plugin name, $2: repo url
install_plugin() {
    local name="$1"
    local url="$2"
    local dir="$OMZ_CUSTOM/plugins/$name"

    info "Installing $name"
    if [ -d "$dir/.git" ]; then
        git -C "$dir" pull --ff-only
    else
        rm -fr "$dir"
        git clone "$url" "$dir"
    fi
}

install_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
install_plugin pure https://github.com/d0u9/pure.git
install_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git

info "Finished"
