#!/bin/bash

set -euo pipefail

# DOT_DIR is exported by parent script
# APP_DIR is exported by parent script
# DOT_LOG_LEVEL is exported by parent script
source "$DOT_DIR/apps/zsh/lib.sh"

info "Installing zellij configurations"

CONFIG_DIR=$(abs_path "$HOME/.config")
ZELLIJ_APP_DIR=$(abs_path "$APP_DIR/zellij")

link_config "$ZELLIJ_APP_DIR" "$CONFIG_DIR/zellij"

info "Finished"
