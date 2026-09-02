-- The LSP servers to install, named as nvim-lspconfig names them (which is
-- what mason-lspconfig's ensure_installed expects). Shared with the bootstrap
-- in apps/nvim-install.sh, which maps them to mason package names.
--
-- https://github.com/mason-org/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
return {
  'rust_analyzer',
  'gopls',
  'lua_ls',
}
