#!/bin/bash

# DOT_DIR is exported by parent script
# APP_DIR is exported by parent script
# DOT_LOG_LEVEL is exported by parent script
source "$DOT_DIR/apps/omz/lib.sh"

info "Installing tmux configurations"

cd $HOME
back_or_override .tmux.conf

TMUX_DIR=$(realpath "$APP_DIR/tmux")
rm "$HOME/.tmux"
ln -fs "$TMUX_DIR" "$HOME/.tmux"

TMUX_CONF=$(realpath "$APP_DIR/tmux/tmux.conf")
ln -fs "$TMUX_CONF" "$HOME/.tmux.conf"

info "Installing plugins"
git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

info "Install finished, you have to manuall execute 'prefix+I' in tmux to install plugins"

