-- The plugin spec handed to lazy.nvim by init.lua.
-- Per-plugin settings live in `plugins/configs/`. Startup-critical settings
-- are loaded by `plugins/setting.lua`; lazy plugin settings are attached to
-- their specs below so configuration runs at the same time as the plugin.
local config = function(module)
  return function()
    require('plugins.configs.' .. module)
  end
end

local fzf = function(picker, opts)
  return function()
    require('fzf-lua')[picker](opts)
  end
end

local open_buffer_files = function()
  local files = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      local filename = vim.api.nvim_buf_get_name(bufnr)
      if filename ~= '' then table.insert(files, filename) end
    end
  end
  return files
end

return {
  -- Enhancement
  { 'nvim-tree/nvim-web-devicons', lazy = true },

  -- Theme
  { 'catppuccin/nvim', name = 'catppuccin' },

  -- LSP plugins
  {
    'neovim/nvim-lspconfig',
    dependencies = 'saghen/blink.cmp',
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
    'saghen/blink.cmp',
    version = '1.*',
    config = config('blink--cmp'),
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
      -- `<C-w><C-w>` used to live here, but it shadowed the most-used window
      -- command there is (cycle to the next window) in both normal and
      -- terminal mode. `<C-\>` is toggleterm's own default and collides with
      -- nothing in the `<C-w>` family. Counts still work: `2<C-\>` opens the
      -- second terminal.
      { [[<C-\>]], '<Cmd>exe v:count1 . "ToggleTerm"<CR>', mode = { 'n', 't' }, desc = 'Toggle terminal' },
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

  -- Fuzzy finder
  {
    'ibhagwan/fzf-lua',
    cmd = 'FzfLua',
    keys = {
      { '<leader>da', fzf('diagnostics_workspace'), desc = 'All diagnostics' },
      { '<leader>dl', fzf('diagnostics_document'), desc = 'Buffer diagnostics' },
      { '<leader>ls', fzf('lsp_document_symbols'), desc = 'Document symbols' },
      { '<leader>ld', fzf('lsp_definitions', { jump1 = false }), desc = 'Definitions' },
      { '<leader>lp', fzf('lsp_implementations'), desc = 'Implementations' },
      -- Neovim's built-in `grt` does this too, but through the quickfix list;
      -- keep it in the picker like the rest of <leader>l*.
      { '<leader>lt', fzf('lsp_typedefs'), desc = 'Type definitions' },
      { '<leader>lf', fzf('lsp_references'), desc = 'References' },
      { '<leader>li', fzf('lsp_incoming_calls'), desc = 'Incoming calls' },
      { '<leader>lo', fzf('lsp_outgoing_calls'), desc = 'Outgoing calls' },
      { '<leader>ff', fzf('files'), desc = 'Find files' },
      { '<leader>fg', fzf('git_files'), desc = 'Git files' },
      { '<leader>fb', fzf('buffers'), desc = 'Buffers' },
      { '<leader>gs', fzf('grep_cword'), desc = 'Grep cursor word' },
      { '<leader>gg', fzf('live_grep'), desc = 'Live grep' },
      {
        '<leader>gc',
        function()
          require('fzf-lua').grep_cword({ search_paths = open_buffer_files() })
        end,
        desc = 'Grep cursor word in open buffers',
      },
      { '<leader>gl', fzf('blines'), desc = 'Search current buffer' },
      { '<leader>tm', fzf('marks'), desc = 'Marks' },
      { '<leader>tj', fzf('jumps'), desc = 'Jump list' },
      { '<leader>tr', fzf('registers'), desc = 'Registers' },
      { '<leader>tq', fzf('quickfix'), desc = 'Quickfix list' },
      { '<leader>tp', fzf('spell_suggest'), desc = 'Spelling suggestions' },
      { '<leader>tk', fzf('keymaps'), desc = 'Keymaps' },
    },
    dependencies = 'nvim-tree/nvim-web-devicons',
    -- `vim.ui.select` has to be claimed before fzf-lua loads, or the first
    -- code action still gets Neovim's built-in numbered prompt -- by the time
    -- `config` runs it is already too late. The shim loads fzf-lua on the
    -- first call and hands straight over to the real picker.
    init = function()
      vim.ui.select = function(...)
        require('fzf-lua').register_ui_select()
        return vim.ui.select(...)
      end
    end,
    config = config('fzf--lua'),
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
      'sindrets/diffview.nvim',
      'ibhagwan/fzf-lua',
    },
    config = config('neogit'),
  },

  -- Enhancement
  -- Replace with w!!
  { 'lambdalisue/suda.vim', cmd = { 'SudaRead', 'SudaWrite' } },
}
