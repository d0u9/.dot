-- Name is different nvim-lspconfig, check this link
-- https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
local ensure_installed = {
  "rust_analyzer",
  "gopls",
  "lua_ls",
}

require("mason-lspconfig").setup({
  ensure_installed = ensure_installed,
})

-- Ref: https://github.com/hrsh7th/nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- Ref: help mason-lspconfig-automatic-server-setup
require("mason-lspconfig").setup_handlers {
  -- The first entry (without a key) will be the default handler
  -- and will be called for each installed server that doesn't have
  -- a dedicated handler.
  function (server_name) -- default handler (optional)
    require("lspconfig")[server_name].setup {
      capabilities = capabilities,
    }
  end,

  -- Next, you can provide a dedicated handler for specific servers.
  -- For example, a handler override for the `rust_analyzer`:
  ["rust_analyzer"] = require('lsp.rust-analyzer').setup,
  ["gopls"] = require('lsp.gopls').setup,
  ["solargraph"] = require('lsp.solargraph').setup,
}


