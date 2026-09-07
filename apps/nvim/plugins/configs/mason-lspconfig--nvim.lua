local wanted = require('plugins.configs.lsp-servers')
local enabled = vim.tbl_filter(function(server)
  -- Mason installs Rust, but rustaceanvim owns its client.
  return server ~= 'rust_analyzer'
end, wanted)

require("mason-lspconfig").setup({
  ensure_installed = wanted,
  automatic_enable = enabled,
})
