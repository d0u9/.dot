#!/bin/bash

set -euo pipefail

# DOT_DIR is exported by parent script
# APP_DIR is exported by parent script
# DOT_LOG_LEVEL is exported by parent script
source "$DOT_DIR/apps/omz/lib.sh"

info "Installing tmux configurations"

TMUX_APP_DIR=$(abs_path "$APP_DIR/tmux")

link_config "$TMUX_APP_DIR" "$HOME/.tmux"
link_config "$TMUX_APP_DIR/tmux.conf" "$HOME/.tmux.conf"

info "Installing plugins"
TPM_DIR="$TMUX_APP_DIR/plugins/tpm"
if [ -d "$TPM_DIR/.git" ]; then
    git -C "$TPM_DIR" pull --ff-only
else
    rm -fr "$TPM_DIR"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

info "Install finished, you have to manuall execute 'prefix+I' in tmux to install plugins"
