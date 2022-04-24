local packer = require('packer')
local util = require('packer.util')

-- Set up directory to store plugins
packer.init({
  package_root = util.join_paths('~/.config/nvim/plugins', 'pack'),
  compile_path = util.join_paths('~/.config/nvim/plugins', 'packer_compiled.lua'),
})

return packer.startup(function()
  -- Theme
  use 'arcticicestudio/nord-vim'
  -- use 'd0u9/nord-vim'


  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Collection of configurations for built-in LSP client
  use 'neovim/nvim-lspconfig'

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
  use { 'itchyny/lightline.vim',
    requires = {
      'tpope/vim-fugitive',
      'liuchengxu/vista.vim',
    }
  }
  use 'itchyny/vim-cursorword'
  use 'wesQ3/vim-windowswap'
  use 'liuchengxu/vista.vim'

  -- treesitter
  use 'nvim-treesitter/nvim-treesitter'
  -- use 'nvim-treesitter/playground'

  -- nvim-tree
  use {
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons'
  }

  -- telescope
  use {
    'nvim-telescope/telescope.nvim',
    requires = 'nvim-lua/plenary.nvim'
  }

  -- Git
  use 'airblade/vim-gitgutter'
  use 'tpope/vim-fugitive'

  -- comment
  use 'b3nj5m1n/kommentary'

  -- Language specific
  use 'simrat39/rust-tools.nvim'
end)

