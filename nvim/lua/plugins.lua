local packer = require('packer')
local util = require('packer.util')

-- Set up directory to store plugins
packer.init({
  package_root = util.join_paths('~/.config/nvim/plugins', 'pack'),
  compile_path = util.join_paths('~/.config/nvim/plugins', 'packer_compiled.lua'),
})

return packer.startup(function()
  -- Theme
  -- use 'arcticicestudio/nord-vim'
  use 'd0u9/nord-vim'


  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Collection of configurations for built-in LSP client
  use 'neovim/nvim-lspconfig'

  -- Autocompletion plugin
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'            -- LSP source for nvim-cmp
  use 'saadparwaiz1/cmp_luasnip'        -- Snippets source for nvim-cmp
  use 'L3MON4D3/LuaSnip'                -- Snippets plugin

  -- GUI relative
  use 'ryanoasis/vim-devicons'
  use 'vim-airline/vim-airline'
  use 'itchyny/vim-cursorword'

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
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- Git
  use {
    'lewis6991/gitsigns.nvim',
    requires = {
      'nvim-lua/plenary.nvim'
    }
  }

  -- comment
  use 'b3nj5m1n/kommentary'

end)

