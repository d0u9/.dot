desc="Neovim binary, configuration, plugins, LSP servers and parsers"
release=(nvim tree-sitter)
link=(".:$HOME/.config/nvim")

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

    info "Installing tree-sitter parsers"
    # Without a compiler nvim still works, with regex highlighting only.
    command_exist cc || {
        warn "no C compiler (cc): parsers skipped; install build-essential or the equivalent, then rerun"
        return 0
    }
    # The config installs these asynchronously on every start; wait for the
    # first run here so a fresh host finishes bootstrapping before returning.
    # nvim exits 0 when a parser fails, so check what is installed afterwards.
    nvim --headless \
        -c 'lua local ts, langs = require("nvim-treesitter"), require("plugins.configs.treesitter-languages")
            ts.install(langs):wait(600000)
            -- Parallel installs can race on the shared cache; retry once.
            local missing = function()
                local have = {}
                for _, l in ipairs(ts.get_installed()) do have[l] = true end
                return vim.tbl_filter(function(l) return not have[l] end, langs)
            end
            if #missing() > 0 then ts.install(missing()):wait(600000) end
            local miss = missing()
            if #miss > 0 then
                io.stderr:write("missing parsers: " .. table.concat(miss, " ") .. "\n")
                vim.cmd("cquit 1")
            end' \
        +qa
}
