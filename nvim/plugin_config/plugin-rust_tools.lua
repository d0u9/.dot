----------- rust-tools.nvim -----------
function config_rust_tools()
  local tools = {
    -- automatically call RustReloadWorkspace when writing to a Cargo.toml file.
    reload_workspace_from_cargo_toml = true,
    autoSetHints = true,
    inlay_hints = {
      show_parameter_hints = true,
      -- parameter_hints_prefix = "<-",
      -- other_hints_prefix = "=>",
    },
  }


  local function on_attach(client, bufnr)
    require("nvim-navic").attach(client, bufnr)
  end

  -- all the opts to send to nvim-lspconfig
  -- these override the defaults set by rust-tools.nvim
  -- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
  local server = {
    on_attach = on_attach,
    settings = {
      ["rust-analyzer"] = {
        -- enable clippy on save
        checkOnSave = {
          command = "clippy"
        },
      }
    }
  }

  local opts = {
    tools = tools,
    server = server,
  }
  require('rust-tools').setup(opts)
  require('rust-tools').inlay_hints.enable()
end

