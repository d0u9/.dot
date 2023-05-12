" linghtline {
    let g:lightline = {
    \ 'colorscheme': 'PaperColor',
    \ 'mode_map': {
    \   'n' : 'NM',
    \   'i' : 'IS',
    \   'R' : 'RP',
    \   'v' : 'VS',
    \   'V' : 'VL ',
    \   "\<C-v>": 'VB',
    \   'c' : 'CM',
    \   's' : 'SE',
    \   'S' : 'SL',
    \   "\<C-s>": 'SB',
    \   't': 'TM',
    \ },
    \ 'active': {
    \ 'left': [ [ 'mode', 'paste' ],
    \           [ 'gitbranch', 'bufwin', 'readonly', 'relativepath', 'modified', 'function' ] ]
    \ },
    \ 'component_function': {
    \   'gitbranch': 'LightlineGitBranch',
    \   'percent': 'LightlinePercent',
    \   'filetype': 'LightlineFiletype',
    \   'fileencoding': 'LightlineFileencoding',
    \   'fileformat': 'LightlineFileformat',
    \   'modified': 'LightlineModified',
    \   'function': 'LightlineNearestMethodOrFunction',
    \   'bufwin': 'LightlineBufWin',
    \ },
    \ 'component': {
    \ },
    \ }

    function! LightlineBufWin()
        return winwidth(0) > 70 ? "\uf2d2 " . win_getid() . " \ufb18 " . bufnr('%'): ''
    endfunction

    function! LightlineModified()
        return &ft ==# 'help' ? "\uf059" : &modified ? "\uf0fe" : &modifiable ? "\uf0c8" : "\uf146"
    endfunction

    function! LightlineGitBranch()
        let l:branch = FugitiveHead()
        return l:branch ==# '' ? '' : " \ue725 " . FugitiveHead()
    endfunction

    function! LightlinePercent()
        let l:percent = (100 * line('.') / line('$'))
        return &ft =~? 'vimfiler' ? '' : printf("\uf718 %03d/%03d %02d%%", line('.'), line('$'), l:percent)
    endfunction

    function! LightlineFiletype()
        return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
    endfunction

    function! LightlineFileencoding()
        return winwidth(0) > 70 ? "\ufbd6 " . &fileencoding : ''
    endfunction

    function! LightlineFileformat()
        return winwidth(0) > 70 ? (&fileformat . ' ' . WebDevIconsGetFileFormatSymbol()) : ''
    endfunction

    function! LightlineNearestMethodOrFunction() abort
      return get(b:, 'vista_nearest_method_or_function', '')
    endfunction
    set statusline+=%{NearestMethodOrFunction()}
    autocmd VimEnter * call vista#RunForNearestMethodOrFunction()
" }

" vista.vim {
    let g:vista_default_executive = 'ctags'
    let g:vista_executive_for = {
        \ 'vimwiki': 'markdown',
        \ 'pandoc': 'markdown',
        \ 'markdown': 'toc',
        \ 'rust': 'nvim_lsp',
        \ 'go': 'nvim_lsp',
        \ 'c': 'nvim_lsp',
        \ 'cpp': 'nvim_lsp',
        \ }
    let g:vista_blink = [0, 0]
    let g:vista_top_level_blink = [0, 0]
    let g:vista_echo_cursor = 0
" }
