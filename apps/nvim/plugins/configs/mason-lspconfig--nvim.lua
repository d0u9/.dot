require("mason-lspconfig").setup({
  ensure_installed = require('plugins.configs.lsp-servers'),
  -- The binary is still installed here, but rustaceanvim is what starts it.
  automatic_enable = {
    exclude = { "rust_analyzer" },
  },
})
