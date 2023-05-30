local function setup_if_has(cb, lib, ...)
  local status, l = pcall(require, lib)
  if (not status) then return end
  for i = 1, select('#', ...) do
    local findit = pcall(require, select(i, ...))
    if (not findit) then return end
  end

  cb()
end

require('plugin-nvim_lspconfig')
setup_if_has(config_nvim_lsconfig, 'lspconfig')

require('plugin-lspkind_nvim')
setup_if_has(config_lspkind_nvim, 'lspkind')

require('plugin-nvim_tree')
setup_if_has(config_nvim_tree, 'nvim-tree')

require('plugin-cmp')
setup_if_has(config_nvim_cmp, 'cmp', 'lspkind')

require('plugin-nvim_treesitter')
setup_if_has(config_nvim_treesitter, 'nvim-treesitter')

require('plugin-telescope')
setup_if_has(config_telescope, 'telescope')

require('plugin-kommentary')
setup_if_has(config_kommentary, 'kommentary')

require('plugin-rust_tools')
setup_if_has(config_rust_tools, 'rust-tools')

require('plugin-ufo')
setup_if_has(config_nvim_ufo, 'ufo', 'nvim-treesitter')

require('plugin-lualine')
setup_if_has(config_lualine, 'lualine')

-- local has_nvimtree, _ = pcall(require, "nvim-tree.lib")
-- if has_nvimtree then
--   require('plugin-gitgutter')
-- end

require('plugin-gitsigns')
setup_if_has(config_gitsigns, 'gitsigns')




