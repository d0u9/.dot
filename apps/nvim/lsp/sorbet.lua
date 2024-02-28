M = {}

local capabilities = require('cmp_nvim_lsp').default_capabilities()
function M.setup()
  require('lspconfig').sorbet.setup{
    capabilities = capabilities,
    settings = {
      solargraph = {
        diagnostics = false,
      },
    },
    cmd = { "srb", "tc", "--lsp", "--disable-watchman" },
  }
end

return M
