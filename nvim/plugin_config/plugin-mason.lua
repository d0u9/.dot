----------- mason -----------
function config_mason()
  local ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }

  local opts = {
    ui = ui,
  }

  require("mason").setup(opts)

  require("mason-lspconfig").setup()
end

