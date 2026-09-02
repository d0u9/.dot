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

if ! command_exist tree-sitter; then
    error "tree-sitter CLI not found; install it first (brew install tree-sitter-cli)"
    error "note that the plain \`tree-sitter\` formula ships only the library"
    exit 1
fi

info "Installing plugins -- lazy.nvim"
# init.lua clones lazy.nvim itself on first start, so a headless run is enough
# to bootstrap it and every plugin in the spec.
nvim --headless "+Lazy! sync" +qa

info "Installing LSP servers -- Mason"
nvim --headless "+MasonInstall lua-language-server rust-analyzer gopls" +qa

info "Installing tree-sitter parsers"
# The config installs these asynchronously on every start; wait for the first
# run here so a fresh host finishes bootstrapping before the script returns.
nvim --headless \
    -c 'lua require("nvim-treesitter").install(require("plugins.configs.treesitter-languages")):wait(600000)' \
    +qa

exit 0
