local function setup_if_has(cb, lib, ...)
  local status, l = pcall(require, lib)
  if (not status) then return end
  for i = 1, select('#', ...) do
    local findit = pcall(require, select(i, ...))
    if (not findit) then return end
  end

  cb()
end

-- https://github.com/onsails/lspkind.nvim
require('plugin-lspkind_nvim')
setup_if_has(config_lspkind_nvim, 'lspkind')

-- https://github.com/nvim-tree/nvim-tree.lua
require('plugin-nvim_tree')
setup_if_has(config_nvim_tree, 'nvim-tree')

-- https://github.com/hrsh7th/nvim-cmp
require('plugin-cmp')
setup_if_has(config_nvim_cmp, 'cmp', 'lspkind')

-- https://github.com/nvim-treesitter/nvim-treesitter
require('plugin-nvim_treesitter')
setup_if_has(config_nvim_treesitter, 'nvim-treesitter')

-- https://github.com/nvim-telescope/telescope.nvim
require('plugin-telescope')
setup_if_has(config_telescope, 'telescope')

-- https://github.com/numToStr/Comment.nvim
require('plugin-comment')
setup_if_has(config_comment, 'Comment')

-- https://github.com/kevinhwang91/nvim-ufo
require('plugin-ufo')
setup_if_has(config_nvim_ufo, 'ufo', 'nvim-treesitter')

-- https://github.com/nvim-lualine/lualine.nvim
require('plugin-lualine')
setup_if_has(config_lualine, 'lualine')

-- https://github.com/sigstore/gitsign
require('plugin-gitsigns')
setup_if_has(config_gitsigns, 'gitsigns')

-- https://github.com/simrat39/symbols-outline.nvim
require('plugin-symbols_outline')
setup_if_has(config_symbols_outline, 'symbols-outline')

------------------------ LSP things ------------------------

-- https://github.com/williamboman/mason.nvim
require('plugin-mason')
setup_if_has(config_mason, 'mason', 'mason-lspconfig', 'lspconfig')

-- https://github.com/jose-elias-alvarez/null-ls.nvim
require('plugin-null_ls')
setup_if_has(config_null_ls, 'null-ls', 'mason')

-- https://github.com/neovim/nvim-lspconfig
require('plugin-nvim_lspconfig')
setup_if_has(config_nvim_lsconfig, 'lspconfig')

-- https://github.com/SmiteshP/nvim-navic
require('plugin-nvim_navic')
setup_if_has(config_nvim_navic, 'symbols-outline', 'lspconfig')

-- https://github.com/simrat39/rust-tools.nvim
require('plugin-rust_tools')
setup_if_has(config_rust_tools, 'rust-tools', 'lspconfig')


