#!/bin/bash

# DOT_DIR is exported by parent script
# APP_DIR is exported by parent script
# DOT_LOG_LEVEL is exported by parent script
source "$DOT_DIR/apps/omz/lib.sh"

info "Installing nvim configurations"


CONFIG_DIR=$(realpath "$HOME/.config")
NVIM_APP_DIR=$(realpath "$APP_DIR/nvim")
TARGET_NVIM_DIR=$(realpath "$CONFIG_DIR/nvim")

mkdir -p "$CONFIG_DIR"
cd $CONFIG_DIR
ln -fs $NVIM_APP_DIR . 2> /dev/null

info "Install nvim plugin manage -- Packer"
PACKER_DIR="$NVIM_APP_DIR/runtime/plugins/pack/packer/start/"
mkdir -p "$PACKER_DIR"
git clone https://github.com/wbthomason/packer.nvim $(realpath "${PACKER_DIR}/packer.nvim")

warn 'install finished, you have to execute `:PackerInstall` in nvim to install plugins'
warn 'Run command below to install code highlights'
warn '    :TSInstall bash c cpp comment go html css javascript json json5 lua markdown python ruby rust toml yaml kdl'

exit 0

nvim --headless -c "MasonInstall lua-language-server rust-analyzer" -c qall

    mkdir -p $HOME/.config
    NVIM_CONF=$DOT_DIR/nvim
    TGT_NVIM_CONF=$HOME/.config/nvim

    back_or_override $TGT_NVIM_CONF
    ln -s $NVIM_CONF $TGT_NVIM_CONF

    git clone https://github.com/wbthomason/packer.nvim $DOT_DIR/nvim/runtime/plugins/pack/packer/start/packer.nvim



