" For deoplete {
    " Auto load deoplete
    let g:deoplete#enable_at_startup = 1

    " Setup deoplete to use TAB
    inoremap <silent><expr> <TAB>
                \ pumvisible() ? "\<C-n>" :
                \ <SID>check_back_space() ? "\<TAB>" :
                \ deoplete#mappings#manual_complete()

    function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~ '\s'
    endfunction

    inoremap <expr><C-h> deoplete#smart_close_popup()."\<C-h>"
    inoremap <expr><BS> deoplete#smart_close_popup()."\<C-h>"
" }


" Vim-airline {
    " let g:airline_powerline_fonts = 1

    " enable spell detection
    let g:airline_detect_spell = 1

    " enable paste detection
    let g:airline_detect_paste = 1

    " enable modified detection
    let g:airline_detect_modified = 1

    let g:airline_theme='dark'
    let g:airline_skip_empty_sections = 1

    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tabline#fnamemod = ':t'
    let g:airline#extensions#tabline#show_tabs = 0

    " define the set of text to display for each mode.
    let g:airline_mode_map = {
                \ '__' : '-',
                \ 'n'  : 'N',
                \ 'i'  : 'I',
                \ 'R'  : 'R',
                \ 'c'  : 'C',
                \ 'v'  : 'V',
                \ 'V'  : 'V',
                \ '' : 'V',
                \ 's'  : 'S',
                \ 'S'  : 'S',
                \ '' : 'S',
                \ }
" }

" ChooseWin {
    nmap - <Plug>(choosewin)
" }

" gitgutter {
    set t_8f=^[[38;2;%lu;%lu;%lum
    set t_8b=^[[48;2;%lu;%lu;%lum
    let g:airline#extensions#tabline#exclude_preview = 1
" }
