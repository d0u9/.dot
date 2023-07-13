M = {}

local capabilities = require('cmp_nvim_lsp').default_capabilities()
function M.setup()
  local on_attach = function(client, bufnr)
    require("nvim-navic").attach(client, bufnr)
  end

  require('lspconfig').gopls.setup{
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = {"gopls", "serve"},
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
      },
    },
  }
end

return M

