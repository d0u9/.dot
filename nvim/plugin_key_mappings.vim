" nvim-cmp {
" See lua/plugin_settings.lua
" }

" telescope {
    " Ref: https://github.com/nvim-telescope/telescope.nvim#mappings
    " Ref: https://github.com/nvim-telescope/telescope.nvim#pickers

    " Lists files in your current working directory, respects .gitignore
    nnoremap <Leader>gf :lua require'telescope.builtin'.find_files()<cr>
    " Fuzzy search through the output of git ls-files command,
    " respects .gitignore, optionally ignores untracked files
    nnoremap <Leader>gl :lua require'telescope.builtin'.git_files()<cr>
    " Searches for the string under your cursor in your current working directory
    nnoremap <Leader>gs :lua require'telescope.builtin'.grep_string()<cr>
    " Search for a string in your current working directory and get results live as you type
    nnoremap <Leader>gg :lua require'telescope.builtin'.live_grep()<cr>

    " Lists files and folders in your current working directory, open files,
    " navigate your filesystem, and create new files and folders
    nnoremap <Leader>sf :lua require'telescope.builtin'.file_browser()<cr>
    " Lists open buffers in current neovim instance
    nnoremap <Leader>sb :lua require'telescope.builtin'.buffers()<cr>

    " Lists LSP references for word under the cursor
    nnoremap <Leader>lr :lua require'telescope.builtin'.lsp_references()<cr>
    " Goto the implementation of the word under the cursor if there's
    " only one, otherwise show all options in Telescope
    nnoremap <Leader>li :lua require'telescope.builtin'.lsp_implementations()<cr>
    " Goto the definition of the word under the cursor, if there's only
    " one, otherwise show all options in Telescope
    nnoremap <Leader>ld :lua require'telescope.builtin'.lsp_definitions()<cr>
" }

" kommentary {
    lua vim.api.nvim_set_keymap("n", "<leader>cc", "<Plug>kommentary_line_default", {})
    lua vim.api.nvim_set_keymap("n", "<leader>c", "<Plug>kommentary_motion_default", {})
    lua vim.api.nvim_set_keymap("x", "<leader>cc", "<Plug>kommentary_visual_default", {})

    lua vim.api.nvim_set_keymap("n", "<leader>cic", "<Plug>kommentary_line_increase", {})
    lua vim.api.nvim_set_keymap("n", "<leader>ci", "<Plug>kommentary_motion_increase", {})
    lua vim.api.nvim_set_keymap("x", "<leader>ci", "<Plug>kommentary_visual_increase", {})
    lua vim.api.nvim_set_keymap("n", "<leader>cdc", "<Plug>kommentary_line_decrease", {})
    lua vim.api.nvim_set_keymap("n", "<leader>cd", "<Plug>kommentary_motion_decrease", {})
    lua vim.api.nvim_set_keymap("x", "<leader>cd", "<Plug>kommentary_visual_decrease", {})
" }
