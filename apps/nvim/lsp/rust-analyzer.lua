M = {}

local capabilities = require('cmp_nvim_lsp').default_capabilities()
function M.setup()
  local settings = {
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
      -- enable clippy on save
      checkOnSave = {
        command = "clippy"
      },
    }
  }
  require('plugins.configs.rust-tools--nvim').setup(settings, capabilities)
end

return M
