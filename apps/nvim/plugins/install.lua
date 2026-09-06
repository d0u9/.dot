-- The plugin spec handed to lazy.nvim by init.lua.
-- Per-plugin settings live in `plugins/configs/`. Startup-critical settings
-- are loaded by `plugins/setting.lua`; lazy plugin settings are attached to
-- their specs below so configuration runs at the same time as the plugin.
local config = function(module)
  return function()
    require('plugins.configs.' .. module)
  end
end

return {
  -- Enhancement
  { 'nvim-tree/nvim-web-devicons', lazy = true },
  { 'nvim-lua/plenary.nvim', lazy = true },

  -- Theme
  { 'catppuccin/nvim', name = 'catppuccin' },

  -- LSP plugins
  {
    'neovim/nvim-lspconfig',
    dependencies = 'hrsh7th/cmp-nvim-lsp',
  },
  'williamboman/mason.nvim',
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
    }
  },
  { 'SmiteshP/nvim-navic', dependencies = 'neovim/nvim-lspconfig' },
  -- This plugin is deprecated
  -- {
  --   'jose-elias-alvarez/null-ls.nvim',
  --   dependencies = 'nvim-lua/plenary.nvim'
  -- },

  -- Language specific - Rust
  { 'mrcjkb/rustaceanvim', ft = { 'rust' } },

  -- Language specific - Golang
  {
    'ray-x/go.nvim',
    -- guihua is what go.nvim uses for floating windows.
    dependencies = 'ray-x/guihua.lua',
    ft = { 'go', 'gomod', 'gowork', 'gotmpl' },
    config = config('go--nvim'),
  },

  -- Autocompletion plugin
  {
    'hrsh7th/nvim-cmp',
    event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      { 'onsails/lspkind-nvim', config = config('lspkind--nvim') },
    },
    config = config('nvim-cmp'),
  },

  -- GUI relative
  {
    'RRethy/vim-illuminate',
    event = { 'BufReadPost', 'BufNewFile' },
    config = config('vim-illuminate'),
  },
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'SmiteshP/nvim-navic' },
    config = config('lualine'),
  },
  {
    'hedyhli/outline.nvim',
    cmd = {
      'Outline', 'OutlineOpen', 'OutlineClose', 'OutlineFocus', 'OutlineFocusCode',
      'OutlineFocusOutline', 'OutlineFollow', 'OutlineRefresh', 'OutlineStatus',
    },
    keys = {
      { '<leader>tt', '<Cmd>Outline<CR>', desc = 'Toggle symbol outline' },
    },
    config = config('outline--nvim'),
  },
  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async', 'nvim-treesitter/nvim-treesitter' },
    ft = { 'rust', 'ruby', 'go', },
    config = config('nvim-ufo'),
  },
  {
    'sindrets/diffview.nvim',
    cmd = {
      'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory', 'DiffviewFocusFiles',
      'DiffviewToggleFiles', 'DiffviewLog', 'DiffviewRefresh',
    },
    config = config('diffview'),
  },
  {
    'akinsho/toggleterm.nvim',
    cmd = {
      'ToggleTerm', 'ToggleTermToggleAll', 'ToggleTermSetName',
      'ToggleTermSendCurrentLine', 'ToggleTermSendVisualLines',
      'ToggleTermSendVisualSelection', 'TermExec', 'TermNew', 'TermSelect',
    },
    keys = {
      { '<C-w><C-w>', '<Cmd>exe v:count1 . "ToggleTerm"<CR>', mode = { 'n', 't' }, desc = 'Toggle terminal' },
    },
    config = config('toggleterm--nvim'),
  },

  -- treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    -- Upstream does not support lazy-loading; TS commands must also be
    -- available when starting without a file.
    lazy = false,
    build = ':TSUpdate',
    config = config('nvim-treesitter'),
  },
  -- 'nvim-treesitter/playground',

  -- nvim-tree
  {
    'kyazdani42/nvim-tree.lua',
    cmd = {
      'NvimTreeToggle', 'NvimTreeOpen', 'NvimTreeClose', 'NvimTreeFindFile',
      'NvimTreeFindFileToggle', 'NvimTreeFocus', 'NvimTreeRefresh', 'NvimTreeResize',
      'NvimTreeCollapse', 'NvimTreeCollapseKeepBuffers', 'NvimTreeClipboard',
      'NvimTreeHiTest',
    },
    keys = {
      { '<leader>`', '<Cmd>NvimTreeToggle<CR>', desc = 'Toggle file tree' },
    },
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = config('nvim-tree'),
  },

  -- telescope
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    keys = {
      { '<leader>da', function() require('telescope.builtin').diagnostics() end, desc = 'All diagnostics' },
      { '<leader>dl', function() require('telescope.builtin').diagnostics({ bufnr = 0, line_width = 'full' }) end, desc = 'Buffer diagnostics (full)' },
      { '<leader>ls', function() require('telescope.builtin').lsp_document_symbols() end, desc = 'Document symbols' },
      { '<leader>ld', function() require('telescope.builtin').lsp_definitions({ jump_type = 'never' }) end, desc = 'Definitions' },
      { '<leader>lp', function() require('telescope.builtin').lsp_implementations() end, desc = 'Implementations' },
      { '<leader>lf', function() require('telescope.builtin').lsp_references() end, desc = 'References' },
      { '<leader>li', function() require('telescope.builtin').lsp_incoming_calls() end, desc = 'Incoming calls' },
      { '<leader>lo', function() require('telescope.builtin').lsp_outgoing_calls() end, desc = 'Outgoing calls' },
      { '<leader>ff', function() require('telescope.builtin').find_files() end, desc = 'Find files' },
      { '<leader>fg', function() require('telescope.builtin').git_files() end, desc = 'Git files' },
      { '<leader>fb', function() require('telescope.builtin').buffers() end, desc = 'Buffers' },
      { '<leader>gs', function() require('telescope.builtin').grep_string() end, desc = 'Grep cursor word' },
      { '<leader>gg', function() require('telescope.builtin').live_grep() end, desc = 'Live grep' },
      { '<leader>gc', function() require('telescope.builtin').grep_string({ grep_open_files = true }) end, desc = 'Grep open files' },
      { '<leader>gl', function() require('telescope.builtin').current_buffer_fuzzy_find() end, desc = 'Search current buffer' },
      { '<leader>tm', function() require('telescope.builtin').marks() end, desc = 'Marks' },
      { '<leader>tj', function() require('telescope.builtin').jumplist() end, desc = 'Jump list' },
      { '<leader>tr', function() require('telescope.builtin').registers() end, desc = 'Registers' },
      { '<leader>tq', function() require('telescope.builtin').quickfix() end, desc = 'Quickfix list' },
      { '<leader>tp', function() require('telescope.builtin').spell_suggest() end, desc = 'Spelling suggestions' },
      { '<leader>tk', function() require('telescope.builtin').keymaps() end, desc = 'Keymaps' },
    },
    dependencies = 'nvim-lua/plenary.nvim',
    config = config('telescope--nvim'),
  },

  -- Git
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = config('gitsigns--nvim'),
  },
  {
    'tpope/vim-fugitive',
    -- Include aliases as well as primary commands so any entry point loads it.
    cmd = {
      'Git', 'G', 'Gdiffsplit', 'Gvdiffsplit', 'Ghdiffsplit', 'Gwrite', 'Gread',
      'GBrowse', 'Gbrowse', 'GDelete', 'Gdelete', 'GMove', 'Gmove',
      'GRemove', 'Gremove', 'GRename', 'Grename', 'GUnlink',
      'GcLog', 'Gclog', 'GlLog', 'Gllog', 'Gcd', 'Glcd', 'Ggrep', 'Glgrep',
      'Gdrop', 'Ge', 'Gedit', 'Gpedit', 'Gr', 'Gsplit', 'Gtabedit', 'Gvsplit',
      'Gw', 'Gwq',
    },
  },
  {
    'NeogitOrg/neogit',
    cmd = 'Neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
    },
    config = config('neogit'),
  },

  -- Enhancement
  -- Replace with w!!
  { 'lambdalisue/suda.vim', cmd = { 'SudaRead', 'SudaWrite' } },
}
