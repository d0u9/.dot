local M = {}

-- Key mapping for neovim's internal functions
local general_keymap = function()
  -- Set leader key
  vim.g.mapleader = ","

  -- Exit form terminal mode
  vim.keymap.set('t', '<C-q>', '<C-\\><C-n>', {noremap = true})


  -- Easier moving in tabs and windows
  -- The lines conflict with the default digraph mapping of <C-K>
  vim.keymap.set('n', '<C-J>', '<C-W>j', {noremap = true})
  vim.keymap.set('n', '<C-K>', '<C-W>k', {noremap = true})
  vim.keymap.set('n', '<C-L>', '<C-W>l', {noremap = true})
  vim.keymap.set('n', '<C-H>', '<C-W>h', {noremap = true})

  -- Most prefer to toggle search highlighting rather than clear the current
  -- search results.
  vim.keymap.set('n', '<leader>/', ':set invhlsearch<CR>', {noremap = true, silent = true})

  -- Visual shifting (does not exit Visual mode)
  vim.keymap.set('v', '<', '<gv', {noremap = true})
  vim.keymap.set('v', '>', '>gv', {noremap = true})


  -- Allow using the repeat operator with a visual selection (!)
  -- http://stackoverflow.com/a/8064607/127816
  vim.keymap.set('v', '.', ':normal .<CR>', {noremap = true})

  -- For when you forget to sudo.. Really Write the file.
  -- `w !sudo tee %` stopped working, so route the same keystrokes through
  -- suda.vim, which is installed for exactly this.
  -- https://github.com/lambdalisue/suda.vim
  vim.keymap.set('c', 'w!!', 'SudaWrite', {noremap = true})


  -- Easier horizontal scrolling
  vim.keymap.set('n', 'zl', 'zL', {noremap = true})
  vim.keymap.set('n', 'zh', 'zH', {noremap = true})

  -- toggle relative line numbers
  vim.keymap.set('n', '<leader>1', ':set relativenumber!<CR>', {noremap = true})

  -- Command-line key bind
  vim.keymap.set('c', '<C-A>', '<Home>', {noremap = true})
  vim.keymap.set('c', '<C-F>', '<Right>', {noremap = true})
  vim.keymap.set('c', '<C-B>', '<Left>', {noremap = true})
  vim.keymap.set('c', '<Esc>b', '<S-Left>', {noremap = true})
  vim.keymap.set('c', '<Esc>f', '<S-Right>', {noremap = true})
  vim.keymap.set('c', '<Esc>d', '<S-Right><C-W>', {noremap = true})

end
general_keymap()

-- Window, Panel, Tabs
local window_and_panel = function()
  -- Windows resizeing
  vim.keymap.set('n', '<C-W>+', ':exe "resize +" .. (&lines * 1/4)<CR>', {noremap = true, silent = true})
  vim.keymap.set('n', '<C-W>-', ':exe "resize -" .. (&lines * 1/4)<CR>', {noremap = true, silent = true})
  vim.keymap.set('n', '<C-W>[', ':exe "vertical resize -" . (&columns * 1/8)<CR>', {noremap = true, silent = true})
  vim.keymap.set('n', '<C-W>]', ':exe "vertical resize +" . (&columns * 1/8)<CR>', {noremap = true, silent = true})
end
window_and_panel()

-- diagnostic key bindings
local diagnostic = function()
  -- Called through a closure, not by value: config.diagnostic wraps
  -- `open_float`, and capturing it here would pin whichever version happened
  -- to exist when this file was required.
  vim.keymap.set('n', '<leader>df', function() vim.diagnostic.open_float() end, { silent = true })
  -- Diagnostic jumping is `[d`/`]d`, which Neovim maps globally itself. The
  -- old `d[`/`d]` shadowed the `d` operator's `d[[`, `d[(` and `d[{` motions,
  -- and the float they opened now comes from `jump.on_jump` in
  -- config.diagnostic, which the built-in mappings pick up too.
end
diagnostic()

-- lsp key bindings
-- for language related things
local lsp = function()
  vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, {noremap = true})
  vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action, {noremap = true})
  vim.keymap.set('n', '<leader>lh', vim.lsp.buf.hover, {noremap = true})
  vim.keymap.set('n', '<leader>lm', vim.lsp.buf.format, {noremap = true})
end
lsp()

local plugin_nvim_tree_attach = function(bufnr)
  local api = require('nvim-tree.api')
  vim.keymap.set('n', '=', api.tree.change_root_to_node, {noremap = true, buffer = bufnr})
end
M.nvim_tree_keymap = plugin_nvim_tree_attach

-- UFO
-- zR/zM/zK are set in plugins/configs/nvim-ufo.lua, which is loaded for the
-- filetypes ufo is enabled on. Requiring `ufo` here would load it everywhere.

-- comment tool
-- Neovim comments lines itself since 0.10: `gcc` for a line, `gc` as an
-- operator. Comment.nvim is no longer installed.

-- Maximize the current window, or restore the layout a previous maximize saved.
-- vim-maximizer did this, but it is a dozen lines of lua and one less plugin.
local maximize_toggle = function()
  if vim.t.maximizer_restore then
    vim.cmd(vim.t.maximizer_restore)
    vim.t.maximizer_restore = nil
  elseif vim.fn.winnr('$') > 1 then
    vim.t.maximizer_restore = vim.fn.winrestcmd()
    vim.cmd('wincmd _ | wincmd |')
  end
end

local window_maximizer = function()
  vim.keymap.set('n', '<leader>zf', maximize_toggle, {desc = 'Toggle window maximize'})
end
window_maximizer()

------------------ LSP Server Specified key bindings ------------------
-- rustaceanvim exposes its extras through `:RustLsp <action>` rather than a
-- lua API to bind against; see plugins/configs/rustaceanvim.lua.

return M
