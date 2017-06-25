" Dein {
    let g:dein#cache_directory=g:dein_cache_dir
" }

" Denite {
    " Ag command on grep source
	let ignore_list = 'exe|so|dll|class|png|jpg|jpeg|doc|docx|pdf|icon|gif'
    call denite#custom#var('grep', 'command', ['ag'])
    call denite#custom#var('grep', 'default_opts',
        \ ['-i', '--vimgrep', '--depth', '5', '--ignore', ignore_list])
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

" nerdcommenter {
    let g:NERDAltDelims_c = 1
    let g:NERDTrimTrailingWhitespace = 1
    let g:NERDSpaceDelims = 1
" }

" gitgutter {
    " Disable all the git-gutter key bindings
    let g:gitgutter_map_keys = 0
    " Show the gutter always
    let g:gitgutter_sign_column_always = 1
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
