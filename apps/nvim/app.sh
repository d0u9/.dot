desc="Neovim binary, configuration, plugins, LSP servers and parsers"
release=(nvim tree-sitter)
link=(".:$HOME/.config/nvim")
items=(treesitter:on)
# init reads this marker: without it the tree-sitter plugins are disabled and
# `Lazy! sync` below removes them.
TS_MARK=$APP_DIR/runtime/treesitter.on

item_install() {
    # Without a working CLI and compiler nvim-treesitter would retry the
    # failing builds on every start; regex highlighting is used instead.
    if ! command_exist cc; then
        warn "no C compiler (cc): tree-sitter disabled; install build-essential or the equivalent, then rerun"
    elif ! tree-sitter --version > /dev/null 2>&1; then
        # The official Linux binary needs a newer glibc than, for example, EL9's 2.34.
        warn "tree-sitter does not run here (glibc too old?): tree-sitter disabled; cargo install tree-sitter-cli, then rerun"
    else
        mkdir -p -- "${TS_MARK%/*}" && : > "$TS_MARK"
        return 0
    fi
    rm -f -- "$TS_MARK"
}
item_uninstall() { rm -f -- "$TS_MARK"; }

post() {
    info "Installing plugins -- lazy.nvim"
    # init.lua clones lazy.nvim itself on first start, so a headless run is
    # enough to bootstrap it and every plugin in the spec.
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

    [ -f "$TS_MARK" ] || return 0
    info "Installing tree-sitter parsers"
    # The config installs these asynchronously on every start; wait for the
    # first run here so a fresh host finishes bootstrapping before returning.
    # nvim exits 0 when a parser fails, so check what is installed afterwards.
    nvim --headless \
        -c 'lua local ts, langs = require("nvim-treesitter"), require("plugins.configs.treesitter-languages")
            ts.install(langs):wait(600000)
            local have = {}
            for _, l in ipairs(ts.get_installed()) do have[l] = true end
            local miss = vim.tbl_filter(function(l) return not have[l] end, langs)
            if #miss > 0 then
                -- Parallel installs can race on the shared cache; rerunning installs only these.
                io.stderr:write("missing parsers: " .. table.concat(miss, " ") .. "; rerun to retry\n")
                vim.cmd("cquit 1")
            end' \
        +qa
}
