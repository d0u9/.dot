local run_cb_if_has = require('lib.utils').run_cb_if_has

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
  -- Not working anymore, use suda function instead
  -- https://github.com/lambdalisue/suda.vim
  vim.keymap.set('c', 'w!!', 'w !sudo tee % >/dev/null', {noremap = true})


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
  vim.keymap.set('n', '<leader>df', vim.diagnostic.open_float, { silent = true })
  vim.keymap.set('n', 'd[', vim.diagnostic.goto_prev)
  vim.keymap.set('n', 'd]', vim.diagnostic.goto_next)
  -- Lists LSP diagnostics for the current workspace if supported, otherwise searches in all open buffers
  vim.keymap.set('n', '<leader>da', "<Cmd>lua require('telescope.builtin').diagnostics()<CR>", { noremap = true, silent = true })
  -- Lists LSP diagnostics for the current buffer
  vim.keymap.set('n', '<leader>dl', "<Cmd>lua require('telescope.builtin').diagnostics({ bufnr=0, line_width='full' })<CR>", { noremap = true, silent = true })
end
run_cb_if_has(diagnostic, 'telescope')

-- lsp key bindings
-- for language related things
local lsp = function()
  vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, {noremap = true})
  vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action, {noremap = true})
  vim.keymap.set('n', '<leader>lm', vim.lsp.buf.format, {noremap = true})
  -- " Goto the definition of the type of the word under the cursor, if there's only one, otherwise show all options in Telescope
  vim.keymap.set('n', '<leader>ls', require('telescope.builtin').lsp_document_symbols, {noremap = true})
  -- " Goto the definition of the word under the cursor, if there's only one, otherwise show all options in Telescope
  vim.keymap.set('n', '<leader>ld', "<Cmd>lua require('telescope.builtin').lsp_definitions({ jump_type='never' })<CR>", {noremap = true})
  -- " Goto the definition of the type of the word under the cursor, if there's only one, otherwise show all options in Telescope
  vim.keymap.set('n', '<leader>lp', require('telescope.builtin').lsp_implementations, {noremap = true})
  -- " Lists LSP references for word under the cursor
  vim.keymap.set('n', '<leader>lf', require('telescope.builtin').lsp_references, {noremap = true})
  -- " Lists LSP incoming calls for word under the cursor
  vim.keymap.set('n', '<leader>li', require('telescope.builtin').lsp_incoming_calls, {noremap = true})
  -- " Lists LSP outgoing calls for word under the cursor
  vim.keymap.set('n', '<leader>lo', require('telescope.builtin').lsp_outgoing_calls, {noremap = true})
end
run_cb_if_has(lsp, 'telescope')

local plugin_telescope_file = function()
  -- " Lists files in your current working directory, respects .gitignore
  vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, {noremap = true})
  -- " Fuzzy search through the output of git ls-files command, respects .gitignore
  vim.keymap.set('n', '<leader>fg', require('telescope.builtin').git_files, {noremap = true})
  -- " Lists open buffers in current neovim instance
  vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers, {noremap = true})
  -- " Lists vim marks and their value
end
run_cb_if_has(plugin_telescope_file, 'telescope')

local plugin_telescope_grep = function()
  -- " Searches for the string under your cursor in your current working directory
  vim.keymap.set('n', '<leader>gs', require('telescope.builtin').grep_string, {noremap = true})

  -- " Search for a string in your current working directory and get results live as you type
  vim.keymap.set('n', '<leader>gg', require('telescope.builtin').live_grep, {noremap = true})

  -- " Searches for the string under your cursor in your current working directory Restrict to currently open files
  vim.keymap.set('n', '<leader>gc', "<Cmd>lua require('telescope.builtin').grep_string({grep_open_files=true})<CR>", {noremap = true})

  -- " Search for a string in your current working directory and get results live as you type Restrict to currently open files
  vim.keymap.set('n', '<leader>gl', require('telescope.builtin').current_buffer_fuzzy_find, {noremap = true})
end

run_cb_if_has(plugin_telescope_grep, 'telescope')

local plugin_telescope_generic = function()
  vim.keymap.set('n', '<leader>tm', require('telescope.builtin').marks, {noremap = true})
  -- " Lists Jump List entries
  vim.keymap.set('n', '<leader>tj', require('telescope.builtin').jumplist, {noremap = true})
  -- " Lists vim registers, pastes the contents of the register on <cr>
  vim.keymap.set('n', '<leader>tr', require('telescope.builtin').registers, {noremap = true})
  -- " Lists items in the quickfix list
  vim.keymap.set('n', '<leader>tq', require('telescope.builtin').quickfix, {noremap = true})
  -- " Lists spelling suggestions for the current word under the cursor, replaces word with selected suggestion on <cr>
  vim.keymap.set('n', '<leader>tp', require('telescope.builtin').spell_suggest, {noremap = true})
  -- " Lists normal mode keymappings
  vim.keymap.set('n', '<leader>tk', require('telescope.builtin').keymaps, {noremap = true})

  -- " Lists all available highlights
  -- vim.keymap.set('n', '<leader>th', require('telescope.builtin').highlights, {noremap = true})
end
run_cb_if_has(plugin_telescope_generic, 'telescope')


local plugin_nvim_tree = function()
  local api = require('nvim-tree.api')
  vim.keymap.set('n', '<leader>`', api.tree.toggle, {noremap = true})
end
run_cb_if_has(plugin_nvim_tree, 'nvim-tree.api')


local plugin_rust_tools = function()
  local api = require('rust-tools')
  vim.keymap.set('n', '<leader>man', api.hover_actions.hover_actions)
end
run_cb_if_has(plugin_rust_tools, 'rust-tools')

-- comment tool
local plugin_comment = function()
  -- NOTE: for comment.nvim keybinding, find it in plugin config.
end
plugin_comment()

-- symbols-outline
local plugin_symbols_outline = function()
  -- NOTE: for other keympas, referce plguin config
  vim.keymap.set('n', '<leader>tt', ':SymbolsOutline<CR>')
end
run_cb_if_has(plugin_symbols_outline, 'symbols-outline')

-- Telescope
local telescope = function()

end
telescope()

local vim_maximizer = function()
  vim.keymap.set('n', '<leader>zf', ':MaximizerToggle<CR>')
end
vim_maximizer()
