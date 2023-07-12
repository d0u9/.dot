---------- nvim-lsconfig -----------
function config_nvim_lsconfig()
  -- For golang
  require('lspconfig').gopls.setup{
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

  -- For Rust
  require('lspconfig').rust_analyzer.setup{
    settings = {
      ["rust-analyzer"] = {
        assist = {
          importGranularity = "module",
          importPrefix = "by_self",
        },
        diagnostics = {
          disabled = {
            "inactive-code",
          }
        },
        cargo = {
          loadOutDirsFromCheck = false
        },
        procMacro = {
          enable = true
        },
      }
    }
  }

  -- For Ruby
  require('lspconfig').solargraph.setup{
    settings = {
      solargraph = {
        diagnostics = false,
      },
    }
  }

  -- For Typescript
  require('lspconfig').eslint.setup({
    -- on_attach = function(client, bufnr)
    --   vim.api.nvim_create_autocmd("BufWritePre", {
    --     buffer = bufnr,
    --     command = "EslintFixAll",
    --   })
    -- end,
  })

  require('lspconfig').tsserver.setup({}
  )
end
