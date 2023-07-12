M = {}

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
  require('plugins.configs.rust-tools--nvim').setup(settings)
end

return M
