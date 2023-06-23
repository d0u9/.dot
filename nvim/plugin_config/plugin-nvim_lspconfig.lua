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
end
