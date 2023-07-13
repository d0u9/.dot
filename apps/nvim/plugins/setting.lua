local require_if_has = require('lib.utils').require_if_has

-- https://github.com/onsails/lspkind.nvim
require_if_has('plugins.configs.lspkind--nvim', 'lspkind')

-- https://github.com/nvim-tree/nvim-tree.lua
require_if_has('plugins.configs.nvim-tree', 'nvim-tree')

-- https://github.com/hrsh7th/nvim-cmp
require_if_has('plugins.configs.nvim-cmp', 'cmp', 'lspkind')

-- https://github.com/nvim-treesitter/nvim-treesitter
require_if_has('plugins.configs.nvim-treesitter', 'nvim-treesitter')

-- https://github.com/nvim-telescope/telescope.nvim
require_if_has('plugins.configs.telescope--nvim', 'telescope')

-- https://github.com/numToStr/Comment.nvim
require_if_has('plugins.configs.comment--nvim', 'Comment')

-- https://github.com/kevinhwang91/nvim-ufo
require_if_has('plugins.configs.nvim-ufo', 'ufo', 'nvim-treesitter')

-- https://github.com/nvim-lualine/lualine.nvim
require_if_has('plugins.configs.lualine', 'lualine')

-- https://github.com/sigstore/gitsign
require_if_has('plugins.configs.gitsign', 'gitsign')

-- https://github.com/simrat39/symbols-outline.nvim
require_if_has('plugins.configs.symbols-outline--nvim', 'symbols-outline')

-- https://github.com/lewis6991/gitsigns.nvim
require_if_has('plugins.configs.gitsigns--nvim', 'gitsigns')

-- https://github.com/RRethy/vim-illuminate
require_if_has('plugins.configs.vim-illuminate', 'illuminate')

-- https://github.com/catppuccin/nvim
require_if_has('plugins.configs.catppuccin', 'catppuccin')

------------------------ LSP things ------------------------

-- https://github.com/simrat39/rust-tools.nvim
require_if_has('plugins.configs.rust-tools--nvim', 'rust-tools', 'lspconfig')

-- https://github.com/williamboman/mason.nvim
require_if_has('plugins.configs.mason--nvim', 'mason', 'lspconfig')

-- https://github.com/williamboman/mason-lspconfig.nvim
require_if_has('plugins.configs.mason-lspconfig--nvim', 'mason', 'mason-lspconfig', 'lspconfig')

-- -- https://github.com/jose-elias-alvarez/null-ls.nvim
require_if_has('plugins.configs.null-ls--nvim', 'null-ls', 'mason')

-- https://github.com/neovim/nvim-lspconfig
require_if_has('plugins.configs.nvim-lspconfig', 'lspconfig')

-- https://github.com/SmiteshP/nvim-navic
require_if_has('plugins.configs.nvim-navic', 'symbols-outline', 'lspconfig')
--
--
--
