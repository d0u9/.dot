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

info "Installing plugins -- lazy.nvim"
# init.lua clones lazy.nvim itself on first start, so a headless run is enough
# to bootstrap it and every plugin in the spec.
nvim --headless "+Lazy! sync" +qa

info "Installing LSP servers -- Mason"
nvim --headless "+MasonInstall lua-language-server rust-analyzer gopls" +qa

warn 'Run command below in nvim to install code highlights'
warn '    :TSInstall bash c cpp comment go html css javascript json json5 lua markdown python ruby rust toml yaml kdl'

exit 0
