M = {}

function M.setup()
  local on_attach = function(client, bufnr)
    require("nvim-navic").attach(client, bufnr)
  end

  require('lspconfig').solargraph.setup{
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      solargraph = {
        diagnostics = false,
      },
    }
  }
end

return M
