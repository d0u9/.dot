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

" Denite {

    nnoremap <silent> <leader>fe :Denite -default-action=open file_rec<CR>
    nnoremap <silent> <leader>fs :Denite -default-action=split file_rec<CR>
    nnoremap <silent> <leader>fv :Denite -default-action=vsplit file_rec<CR>
    nnoremap <silent> <leader>fy :Denite -default-action=yank file_rec<CR>

    nnoremap <silent> <leader>me :Denite -default-action=open file_mru<CR>
    nnoremap <silent> <leader>ms :Denite -default-action=split file_mru<CR>
    nnoremap <silent> <leader>mv :Denite -default-action=vsplit file_mru<CR>
    nnoremap <silent> <leader>my :Denite -default-action=yank file_mru<CR>

    nnoremap <silent> <leader>ge :DeniteCursorWord -default-action=open grep<CR>
    nnoremap <silent> <leader>gs :DeniteCursorWord -default-action=split grep<CR>
    nnoremap <silent> <leader>gv :DeniteCursorWord -default-action=vsplit grep<CR>
    nnoremap <silent> <leader>gy :DeniteCursorWord -default-action=yank grep<CR>
    nnoremap <silent> <leader>gge :Denite -default-action=open grep<CR>
    nnoremap <silent> <leader>ggs :Denite -default-action=split grep<CR>
    nnoremap <silent> <leader>ggv :Denite -default-action=vsplit grep<CR>
    nnoremap <silent> <leader>ggy :Denite -default-action=yank grep<CR>

    nnoremap <silent> <leader>se :DeniteCursorWord -default-action=open line<CR>
    nnoremap <silent> <leader>ss :DeniteCursorWord -default-action=split line<CR>
    nnoremap <silent> <leader>sv :DeniteCursorWord -default-action=vsplit line<CR>
    nnoremap <silent> <leader>sy :DeniteCursorWord -default-action=yank line<CR>
    nnoremap <silent> <leader>sse :Denite -default-action=open line<CR>
    nnoremap <silent> <leader>sss :Denite -default-action=split line<CR>
    nnoremap <silent> <leader>ssv :Denite -default-action=vsplit line<CR>
    nnoremap <silent> <leader>ssy :Denite -default-action=yank line<CR>

    nnoremap <silent> <leader>be :Denite -default-action=open buffer<CR>
    nnoremap <silent> <leader>bs :Denite -default-action=split buffer<CR>
    nnoremap <silent> <leader>bv :Denite -default-action=vsplit buffer<CR>
    nnoremap <silent> <leader>by :Denite -default-action=yank buffer<CR>
    nnoremap <silent> <leader>bx :Denite -default-action=delete buffer<CR>

    nnoremap <silent> <leader>oe :Denite -default-action=open outline<CR>
    nnoremap <silent> <leader>os :Denite -default-action=split outline<CR>
    nnoremap <silent> <leader>ov :Denite -default-action=vsplit outline<CR>

    nnoremap <silent> <leader>oc :Denite -default-action=default command_history<CR>
    nnoremap <silent> <leader>oy :Denite -default-action=default neoyank<CR>
" }

" deoplete {
    " Setup deoplete to use TAB
    inoremap <silent><expr> <TAB>
                \ pumvisible() ? "\<C-n>" :
                \ <SID>check_back_space() ? "\<TAB>" :
                \ deoplete#manual_complete()
    function! s:check_back_space() abort "{{{
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~ '\s'
    endfunction"}}}

    inoremap <expr><C-h> deoplete#smart_close_popup()."\<C-h>"
    inoremap <expr><BS> deoplete#smart_close_popup()."\<C-h>"
" }

" ChooseWin {
    nmap <silent> <Leader>ww <Plug>(choosewin)
" }

" undotree {
    nnoremap <leader>ut :UndotreeToggle<cr>
" }

" NERDtree {
    nnoremap <silent> <F3> :NERDTreeToggle<cr>
" }

" tagbar {
    nnoremap <silent> <F4> :TagbarToggle<CR>
" }


" LanguageClient-neovim {
    nnoremap <silent> <leader>cd :call LanguageClient#textDocument_hover()<CR>
    nnoremap <silent> <leader>cr :call LanguageClient#textDocument_rename()<CR>
" }
