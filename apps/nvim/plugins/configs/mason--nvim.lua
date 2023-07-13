local ui = {
  icons = {
    package_installed = "✓",
    package_pending = "➜",
    package_uninstalled = "✗"
  }
}

local opts = {
  -- The directory in which to install packages.
  install_root_dir = _G.MASON_DIR,
  ui = ui,
}
require("mason").setup(opts)
