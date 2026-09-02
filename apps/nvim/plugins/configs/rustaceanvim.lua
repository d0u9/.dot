-- rustaceanvim is the maintained successor of rust-tools.nvim, which its
-- author archived pointing here.
--
-- Unlike rust-tools it starts rust-analyzer itself rather than going through
-- lspconfig, so `rust_analyzer` must not also be enabled elsewhere -- see
-- plugins/configs/nvim-cmp.lua and mason-lspconfig--nvim.lua.
--
-- Everything is driven by the `:RustLsp` command, e.g.
--   :RustLsp hover actions
--   :RustLsp codeAction
--   :RustLsp runnables
--   :RustLsp expandMacro
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local on_attach = function(client, bufnr)
  require("nvim-navic").attach(client, bufnr)
end

-- Read once, when the first rust buffer opens.
vim.g.rustaceanvim = {
  tools = {
    hover_actions = {
      auto_focus = false,
    },
    reload_workspace_from_cargo_toml = true,
  },
  server = {
    capabilities = capabilities,
    on_attach = on_attach,
    default_settings = {
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
        checkOnSave = true,
        check = {
          command = "clippy",
        },
        inlayHints = {
          parameterHints = { enable = true },
        },
      }
    },
  },
}
