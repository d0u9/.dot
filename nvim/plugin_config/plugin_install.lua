local packer = require('packer')
local util = require('packer.util')

-- Set up directory to store plugins
packer.init({
  package_root = util.join_paths(_G.PLUGIN_DIR, 'pack'),
  compile_path = util.join_paths(_G.PLUGIN_DIR, 'packer_compiled.lua'),
})

return packer.startup(function()
  -- Enhancement
  use 'nvim-lua/plenary.nvim'

  -- Theme
  use 'arcticicestudio/nord-vim'

  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- LSP plugins
  use 'neovim/nvim-lspconfig'
  use 'williamboman/mason.nvim'
  use {
    'williamboman/mason-lspconfig.nvim',
    requires = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
    }
  }
  use {
    'SmiteshP/nvim-navic',
    requires = 'neovim/nvim-lspconfig'
  }
  use {
    'jose-elias-alvarez/null-ls.nvim',
    requires = 'nvim-lua/plenary.nvim'
  }
  -- Language specific - Rust
  use 'simrat39/rust-tools.nvim'


  -- Autocompletion plugin
  use { 'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/vim-vsnip',
    }
  }

  -- GUI relative
  use 'ryanoasis/vim-devicons'
  use 'onsails/lspkind-nvim'
  use {
      'nvim-lualine/lualine.nvim',
      requires = {
        'nvim-tree/nvim-web-devicons', opt = true
      }
  }
  use 'itchyny/vim-cursorword'
  use 'wesQ3/vim-windowswap'
  use 'simrat39/symbols-outline.nvim'
  use {
    'kevinhwang91/nvim-ufo',
    requires = 'kevinhwang91/promise-async'
  }

  -- treesitter
  use 'nvim-treesitter/nvim-treesitter'
  -- use 'nvim-treesitter/playground'

  -- nvim-tree
  use {
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons',
  }

  -- telescope
  use {
    'nvim-telescope/telescope.nvim',
    requires = 'nvim-lua/plenary.nvim'
  }

  -- Git
  use 'lewis6991/gitsigns.nvim'
  use 'tpope/vim-fugitive'

  -- comment
  use 'numToStr/Comment.nvim'

  -- Enhancement
  use 'lambdalisue/suda.vim'

  -- Deprecated
  -- use {
  --     'itchyny/lightline.vim',
  --     requires = {
  --       'tpope/vim-fugitive',
  --       'liuchengxu/vista.vim',
  --   }
  -- }
  --
  -- use 'airblade/vim-gitgutter'
  -- use 'b3nj5m1n/kommentary'
  -- use 'liuchengxu/vista.vim'

end)

