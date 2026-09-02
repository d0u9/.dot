-- The plugin spec handed to lazy.nvim by init.lua.
-- Per-plugin settings live in `plugins/configs/`, and are loaded by
-- `plugins/setting.lua` after lazy has put the plugins on the runtimepath.
return {
  -- Enhancement
  'nvim-tree/nvim-web-devicons',
  'nvim-lua/plenary.nvim',

  -- Theme
  { 'catppuccin/nvim', name = 'catppuccin' },

  -- LSP plugins
  'neovim/nvim-lspconfig',
  'williamboman/mason.nvim',
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
    }
  },
  {
    'SmiteshP/nvim-navic',
    dependencies = 'neovim/nvim-lspconfig'
  },
  -- This plugin is deprecated
  -- {
  --   'jose-elias-alvarez/null-ls.nvim',
  --   dependencies = 'nvim-lua/plenary.nvim'
  -- },

  -- Language specific - Rust
  'mrcjkb/rustaceanvim',
  'IndianBoy42/tree-sitter-just',

  -- Language specific - Golang
  'ray-x/go.nvim',
  'ray-x/guihua.lua', -- recommended if need floating window support

  -- Autocompletion plugin
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/vim-vsnip',
      'hrsh7th/cmp-vsnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-nvim-lsp-signature-help',
    }
  },

  -- GUI relative
  'RRethy/vim-illuminate',
  'onsails/lspkind-nvim',
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },
  'wesQ3/vim-windowswap',
  'hedyhli/outline.nvim',
  {
    'kevinhwang91/nvim-ufo',
    dependencies = 'kevinhwang91/promise-async',
    ft = { 'rust', 'ruby', 'go', },
  },
  'szw/vim-maximizer',
  'sindrets/diffview.nvim',
  'akinsho/toggleterm.nvim',

  -- treesitter
  -- The default branch is the rewritten v1.x, which dropped the
  -- `nvim-treesitter.configs` module `plugins/configs/nvim-treesitter.lua`
  -- is written against; stay on the classic branch.
  { 'nvim-treesitter/nvim-treesitter', branch = 'master' },
  -- 'nvim-treesitter/playground',

  -- nvim-tree
  {
    'kyazdani42/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    }
  },

  -- telescope
  {
    'nvim-telescope/telescope.nvim',
    dependencies = 'nvim-lua/plenary.nvim'
  },

  -- Git
  'lewis6991/gitsigns.nvim',
  'tpope/vim-fugitive',
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
    }
  },

  -- Enhancement
  -- Replace with w!!
  'lambdalisue/suda.vim',
}
