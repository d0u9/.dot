#!/bin/bash

# DOT_DIR is exported by parent script
# APP_DIR is exported by parent script
# DOT_LOG_LEVEL is exported by parent script
source "$DOT_DIR/apps/oh-my-zsh/lib.sh"

info "Installing zellij configurations"

CONFIG_DIR=$(realpath "$HOME/.config")
ZELLIJ_DIR=$(realpath "$APP_DIR/zellij")

mkdir -p "$CONFIG_DIR"
cd "$CONFIG_DIR"
rm -f zellij
ln -s $ZELLIJ_DIR .

info "Finished"
