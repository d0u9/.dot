#!/bin/bash

set -euo pipefail

# DOT_DIR is exported by parent script
# APP_DIR is exported by parent script
# DOT_LOG_LEVEL is exported by parent script
source "$DOT_DIR/apps/zsh/lib.sh"

info "Installing nvim configurations"

CONFIG_DIR=$(abs_path "$HOME/.config")
NVIM_APP_DIR=$(abs_path "$APP_DIR/nvim")

link_config "$NVIM_APP_DIR" "$CONFIG_DIR/nvim"

if ! command_exist nvim; then
    error "nvim not found; install it first"
    exit 1
fi

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
# mason-lspconfig's `ensure_installed` is skipped in headless mode, so the
# bootstrap installs the same list explicitly. The server names live in
# plugins/configs/lsp-servers.lua; mason knows them under different package
# names, so translate. MasonInstall blocks when headless.
nvim --headless \
    -c 'lua local m = require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package
        local pkgs = vim.tbl_map(function(s) return m[s] end, require("plugins.configs.lsp-servers"))
        vim.cmd("MasonInstall " .. table.concat(pkgs, " "))' \
    +qa \
    || warn 'some LSP servers failed to install; see doc/install.md for their toolchain requirements'

info "Installing tree-sitter parsers"
# The config installs these asynchronously on every start; wait for the first
# run here so a fresh host finishes bootstrapping before the script returns.
nvim --headless \
    -c 'lua require("nvim-treesitter").install(require("plugins.configs.treesitter-languages")):wait(600000)' \
    +qa

info "Finished"
