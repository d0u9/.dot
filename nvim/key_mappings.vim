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
    map <leader>1 :set relativenumber!<CR>

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
