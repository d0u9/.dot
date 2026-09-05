#!/bin/bash

set -euo pipefail

# DOT_DIR is exported by parent script
# APP_DIR is exported by parent script
# DOT_LOG_LEVEL is exported by parent script
source "$DOT_DIR/apps/omz/lib.sh"

info "Installing Alacritty configurations"

CONFIG_DIR=$(abs_path "$HOME/.config")
ALACRITTY_APP_DIR=$(abs_path "$APP_DIR/alacritty")

link_config "$ALACRITTY_APP_DIR" "$CONFIG_DIR/alacritty"

info "Install alacritty plugins -- catppuccin"
CATPPUCCIN_DIR="$ALACRITTY_APP_DIR/plugins/catppuccin"
mkdir -p "$CATPPUCCIN_DIR"
for flavour in latte frappe macchiato mocha; do
    if ! curl -fLo "$CATPPUCCIN_DIR/catppuccin-$flavour.toml" \
        "https://github.com/catppuccin/alacritty/raw/main/catppuccin-$flavour.toml"; then
        error "failed to download the $flavour flavour"
        exit 1
    fi
done

info "Finished"
