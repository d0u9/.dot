" dein {
    let g:dein#cache_directory=g:dein_cache_dir
" }

" deoplete {
    " Auto load deoplete
    let g:deoplete#enable_at_startup = 1
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
    let g:airline#extensions#tabline#exclude_preview = 1

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

" gitgutter {
    " Disable all the git-gutter key bindings
    let g:gitgutter_map_keys = 0
    " Show the gutter always
    let g:gitgutter_sign_column_always = 1
" }
