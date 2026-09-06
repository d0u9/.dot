local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Apply completion capabilities to every server enabled by mason-lspconfig.
vim.lsp.config('*', {
  capabilities = capabilities,
})

local wanted = {}
for _, server in ipairs(require('plugins.configs.lsp-servers')) do
  wanted[server] = true
end

-- Do not register or enable gopls on hosts without a Go toolchain. The same
-- wanted-server list also drives Mason installation and automatic enabling.
if wanted.gopls then
  vim.lsp.config('gopls', {
    cmd = { 'gopls', 'serve' },
    on_attach = function(client, bufnr)
      require('nvim-navic').attach(client, bufnr)
    end,
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
      },
    },
  })
end
