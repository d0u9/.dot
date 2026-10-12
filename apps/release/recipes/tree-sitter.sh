# tree-sitter CLI: https://github.com/tree-sitter/tree-sitter/releases
# Assets are tree-sitter-cli-{macos,linux}-{arm64,x64}.zip holding only the
# tree-sitter executable; Neovim's nvim-treesitter needs it to build parsers.
release_repo=tree-sitter/tree-sitter
release_bin=tree-sitter
release_asset() {
    local cpu=$2
    [ "$cpu" = x86_64 ] && cpu=x64
    printf 'tree-sitter-cli-%s-%s.zip\n' "$1" "$cpu"
}
