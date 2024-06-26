#!/bin/bash

# DOT_DIR is exported by parent script
# APP_DIR is exported by parent script
# DOT_LOG_LEVEL is exported by parent script
source "$DOT_DIR/apps/omz/lib.sh"

info "Installing oh-my-zsh configurations"

CONFIG_DIR=$(realpath "$HOME/.config")
OMZ_DIR=$(realpath "$APP_DIR/omz")
OMZ_CONF_FILE=$(realpath "$OMZ_DIR/zshrc")
OMZ_THEME_DIR=$(realpath "$OMZ_DIR/themes")

cd $HOME
back_or_override .zshrc

ln -fs "$OMZ_CONF_FILE" .zshrc

info "Installing themes"
cd $HOME/.oh-my-zsh/themes
# Delete all dead links
find . -type l ! -exec test -e {} \; -delete

for file in "$OMZ_THEME_DIR"/*.zsh-theme; do
    ln -fs "$file" .
done

info "Installing zsh-autosuggestions"
rm -fr "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

info "Install My Pure Theme"
rm -fr "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/pure"
git clone https://github.com/d0u9/pure.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/pure"

info "Install zsh-syntax-highlighting"
rm -fr "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

info "Finished"
