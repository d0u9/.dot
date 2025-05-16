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
