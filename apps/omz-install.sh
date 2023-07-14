#!/bin/bash

# DOT_DIR is exported by parent script
# APP_DIR is exported by parent script
# DOT_LOG_LEVEL is exported by parent script
source "$DOT_DIR/apps/omz/lib.sh"

info "Installing oh-my-zsh configurations"

CONFIG_DIR=$(realpath "$HOME/.config")
OMZ_DIR=$(realpath "$APP_DIR/omz")
OMZ_CONF_FILE=$(realpath "$OMZ_DIR/zshrc")
THEME_NAME="d0u9.zsh-theme"
OMZ_THEME_FILE=$(realpath "$OMZ_DIR/oh-my-zsh_themes/$THEME_NAME")

cd $HOME
back_or_override .zshrc

rm -f .zshrc
ln -s "$OMZ_CONF_FILE" .zshrc

info "Installing theme"
cd $HOME/.oh-my-zsh/themes
rm -f $THEME_NAME
ln -s "$OMZ_THEME_FILE" .

info "Installing zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


info "Finished"
