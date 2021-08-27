" General Mapping {
    " Set leader key
    let mapleader=","

    " Exit form terminal mode
    tnoremap <c-q> <c-\><c-n>

    " Easier moving in tabs and windows
    " The lines conflict with the default digraph mapping of <C-K>
    map <C-J> <C-W>j
    map <C-K> <C-W>k
    map <C-L> <C-W>l
    map <C-H> <C-W>h

    " Most prefer to toggle search highlighting rather than clear the current
    " search results.
    nmap <silent> <leader>/ :set invhlsearch<CR>

    " Visual shifting (does not exit Visual mode)
    vnoremap < <gv
    vnoremap > >gv

    " Allow using the repeat operator with a visual selection (!)
    " http://stackoverflow.com/a/8064607/127816
    vnoremap . :normal .<CR>

    " For when you forget to sudo.. Really Write the file.
    cmap w!! w !sudo tee % >/dev/null

    " Easier horizontal scrolling
    map zl zL
    map zh zH

    " toggle relative line numbers
    map <F2> :set relativenumber!<CR>

    " Command-line key bin
    cnoremap <C-A> <Home>
    cnoremap <C-F> <Right>
    cnoremap <C-B> <Left>
    cnoremap <Esc>b <S-Left>
    cnoremap <Esc>f <S-Right>
" }

" Window, Panel, Tabs {
    " Windows resizeing
    nnoremap <silent> <Leader>wk :exe "resize +" . (&lines * 1/4)<CR>
    nnoremap <silent> <Leader>wj :exe "resize -" . (&lines * 1/4)<CR>
    nnoremap <silent> <Leader>wl :exe "vertical resize -" . (&columns * 1/8)<CR>
    nnoremap <silent> <Leader>wh :exe "vertical resize +" . (&columns * 1/8)<CR>

    " Adjust viewports to the same size
    map <Leader>w= <C-w>=

    " Also check ChooseWin's documentation for more window and tab
    " manipulations.
" }

"""""""""""""""""" key bindings for specific plugins """"""""""""""""""""""""

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

