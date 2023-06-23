----------- rust-tools.nvim -----------
function config_rust_tools()
  local opts = {
    tools = {
      -- automatically call RustReloadWorkspace when writing to a Cargo.toml file.
      reload_workspace_from_cargo_toml = true,
      autoSetHints = true,
      inlay_hints = {
        show_parameter_hints = true,
        -- parameter_hints_prefix = "<-",
        -- other_hints_prefix = "=>",
      },
    },

    -- all the opts to send to nvim-lspconfig
    -- these override the defaults set by rust-tools.nvim
    -- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
    server = {
      -- on_attach is a callback called when the language server attachs to the buffer
      -- on_attach = on_attach,
      settings = {
        -- to enable rust-analyzer settings visit:
        -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
        ["rust-analyzer"] = {
          -- enable clippy on save
          checkOnSave = {
            command = "clippy"
          },
        }
      }
    },
  }
  require('rust-tools').setup(opts)
end
