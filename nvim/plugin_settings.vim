" Dein {
    let g:dein#cache_directory=g:dein_cache_dir
" }

" Denite {
    autocmd FileType denite call s:denite_my_settings()
    function! s:denite_my_settings() abort
        nnoremap <silent><buffer><expr> <CR>
                    \ denite#do_map('do_action')
        nnoremap <silent><buffer><expr> d
                    \ denite#do_map('do_action', 'delete')
        nnoremap <silent><buffer><expr> p
                    \ denite#do_map('do_action', 'preview')
        nnoremap <silent><buffer><expr> q
                    \ denite#do_map('quit')
        nnoremap <silent><buffer><expr> i
                    \ denite#do_map('open_filter_buffer')
        nnoremap <silent><buffer><expr> <Space>
                    \ denite#do_map('toggle_select').'j'
    endfunction

    call denite#custom#source('line,grep', 'max_candidates', 100000)

    " Ag command on grep source
    let ignore_list = 'exe|so|dll|class|png|jpg|jpeg|doc|docx|pdf|icon|gif|out'
    call denite#custom#var('grep', 'command', ['ag'])
    call denite#custom#var('grep', 'default_opts',
        \ ['-Qr', '--vimgrep', '--depth', '5', '--ignore', ignore_list])
    call denite#custom#var('grep', 'recursive_opts', [])
    call denite#custom#var('grep', 'pattern_opt', [])
    call denite#custom#var('grep', 'separator', ['--'])
    call denite#custom#var('grep', 'final_opts', [])

    call denite#custom#filter('matcher_ignore_globs', 'ignore_globs',
        \ [ '*~', '*.o', '*.exe', '*.bak', '.DS_Store', '*.pyc', '*.sw[po]',
        \   '*.class', '.hg/', '.git/', '.bzr/', '.svn/', 'tags', 'tags-*',
        \   '*.out', '*.jpg', '*.so', '*.dll', '*.png', '*.jpeg', '*.doc',
        \   '*.docx', '*.bin', '*.icon', '*.pdf', '*.gif'
        \ ])

    call denite#custom#source('file_rec', 'matchers',
        \ ['matcher_fuzzy', 'matcher_ignore_globs'])

" }

" neomru {
    let g:neomru#directory_mru_path = g:neomru_dir . "/neodirectory.txt"
    let g:neomru#file_mru_path = g:neomru_dir . "/neofile.txt"
    let g:neomru#file_mru_limit = 300
" }

" neoyank {
    let g:neoyank#file = g:neoyank_file
" }

" deoplete {
    " Auto load deoplete
    let g:deoplete#enable_at_startup = 1

    call deoplete#custom#option('deoplete-options-auto_complete', 1)
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

    let g:airline#extensions#tagbar#enabled = 1
    let g:airline_section_warning = ''

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

" nerdcommenter {
    let g:NERDAltDelims_c = 1
    let g:NERDTrimTrailingWhitespace = 1
    let g:NERDSpaceDelims = 1
" }

" gitgutter {
    " Disable all the git-gutter key bindings
    let g:gitgutter_map_keys = 0
    " Show the gutter always
    "let g:gitgutter_sign_column_always = 1, obsoleted
    set signcolumn=yes
" }

" undotree {
    let g:undotree_SplitWidth = 50
    let g:undotree_WindowLayout = 2
" }

" NERDtree {
    map <F3> :NERDTreeToggle<cr>
    let NERDTreeWinSize = 33
    let NERDTreeShowBookmarks = 1
    let NERDTreeIgnore = ['\.pyc', '\~$', '\.swo$', '\.swp$', '\.git', '\.hg', '\.svn', '\.bzr']
    let NERDTreeChDirMode = 0
    let NERDTreeMouseMode = 2
    let NERDTreeShowHidden = 1
    let NERDTreeBookmarksFile = expand('$HOME') . '/.config/nvim/NERDTreeBookmarks'
" }

" vim-devicons {
    autocmd FileType nerdtree setlocal nolist
    let g:WebDevIconsNerdTreeAfterGlyphPadding = ''
" }

" vim-markdown {
    let g:vim_markdown_folding_disabled = 1

" }

" deoplete-clang2 {
    let g:deoplete#sources#clang#executable = system("which clang | tr -d '\n'")
" }

" vim-choosewin {
    nmap  \  <Plug>(choosewin)
    let g:choosewin_overlay_enable = 1
" }

" vim-table-mode {
    let g:table_mode_corner='|'
" }

" tag-bar {
    let g:tagbar_type_go = {
        \ 'ctagstype' : 'go',
        \ 'kinds'     : [
            \ 'p:package',
            \ 'i:imports:1',
            \ 'c:constants',
            \ 'v:variables',
            \ 't:types',
            \ 'n:interfaces',
            \ 'w:fields',
            \ 'e:embedded',
            \ 'm:methods',
            \ 'r:constructor',
            \ 'f:functions'
        \ ],
        \ 'sro' : '.',
        \ 'kind2scope' : {
            \ 't' : 'ctype',
            \ 'n' : 'ntype'
        \ },
        \ 'scope2kind' : {
            \ 'ctype' : 't',
            \ 'ntype' : 'n'
        \ },
        \ 'ctagsbin'  : 'gotags',
        \ 'ctagsargs' : '-sort -silent'
    \ }
" }
