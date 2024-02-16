#!/bin/bash

# DOT_DIR is exported by parent script
# APP_DIR is exported by parent script
# DOT_LOG_LEVEL is exported by parent script
source "$DOT_DIR/apps/omz/lib.sh"

info "Installing Alacritty configurations"


CONFIG_DIR=$(realpath "$HOME/.config")
ALACRITTY_APP_DIR=$(realpath "$APP_DIR/alacritty")
TARGET_ALACRITTY_DIR=$(realpath "$CONFIG_DIR/alacritty")

mkdir -p "$CONFIG_DIR"
cd $CONFIG_DIR
ln -fs $ALACRITTY_APP_DIR . 2> /dev/null

info "Install alacritty plugins -- catppuccin"
CATPPUCCIN_DIR="$ALACRITTY_APP_DIR/plugins/catppuccin"
mkdir -p "$CATPPUCCIN_DIR"
curl -LO --output-dir $ALACRITTY_APP_DIR/plugins/catppuccin/ https://github.com/catppuccin/alacritty/raw/main/catppuccin-latte.toml
curl -LO --output-dir $ALACRITTY_APP_DIR/plugins/catppuccin/ https://github.com/catppuccin/alacritty/raw/main/catppuccin-frappe.toml
curl -LO --output-dir $ALACRITTY_APP_DIR/plugins/catppuccin/ https://github.com/catppuccin/alacritty/raw/main/catppuccin-macchiato.toml
curl -LO --output-dir $ALACRITTY_APP_DIR/plugins/catppuccin/ https://github.com/catppuccin/alacritty/raw/main/catppuccin-mocha.toml

exit 0

