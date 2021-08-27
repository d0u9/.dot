" Identify platform {
    silent function! OSX()
        return has('macunix')
    endfunction

    silent function! LINUX()
        return has('unix') && !has('macunix') && !has('win32unix')
    endfunction

    silent function! WINDOWS()
        return  (has('win32') || has('win64'))
    endfunction
" }

" General settings {
    set background=dark

    filetype plugin indent on           " Automatically detect file types.
    syntax on                           " Syntax highlighting
    set mousehide                       " Hide the mouse cursor while typing
    set noeol

    set shortmess+=filmnrxoOtT          " Avoiding the 'Hit ENTER to continue' prompts
    set viewoptions=folds,options,cursor,unix,slash " Better Unix / Windows compatibility
    set virtualedit=onemore             " Allow for cursor beyond last character
    set hidden                          " Allow buffer switching without saving

    " The 'iskeyword' option specifies which characters can appear in a word
    set iskeyword-=.                    " '.' is an end of word designator
    set iskeyword-=#                    " '#' is an end of word designator
    set iskeyword-=-                    " '-' is an end of word designator

    " Instead of reverting the cursor to the last position in the buffer,
    " we set it to the first line when editing a git commit message
    au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

    " Git spell check
    autocmd Filetype gitcommit setlocal spell textwidth=72

    set backup                      " Backups are nice ...
    if has('persistent_undo')
        execute 'set undodir=' . g:undo_dir
        set undofile                " So is persistent undo ...
        set undolevels=1000         " Maximum number of changes that can be undone
        set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
    endif

    " http://vim.wikia.com/wiki/Remove_swap_and_backup_files_from_your_working_directory
    execute 'set backupdir=' . g:backup_dir . ',/tmp'
    execute 'set directory=' . g:swap_dir . ',tmp'

    " set UTF-8 encoding
    set fileencoding=utf-8
    scriptencoding utf-8

    " Share content with the system's clipboard
    set clipboard+=unnamedplus
" }

" Vim UI {
    " Set the color scheme
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
    set t_Co=256

    set showmode                    " Display the current mode

    set colorcolumn=80              " Highligh the column 80

    " Highlight current line and column
    set cursorline
    set cursorcolumn

    highlight clear SignColumn      " SignColumn should match background
    highlight clear LineNr          " Current line number row will have same background color in relative mode

    set ruler                       " Show the ruler
    set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " A ruler on steroids
    set showcmd                     " Show partial commands in status line and
                                    " Selected characters/lines in visual mode

    if has('statusline')

        " Broken down into easily includeable segments
        set statusline=%<%f\                     " Filename
        set statusline+=%w%h%m%r                 " Options
        "if !exists('g:override_spf13_bundles')
            "set statusline+=%{fugitive#statusline()} " Git Hotness
        "endif
        set statusline+=\ [%{&ff}/%Y]            " Filetype
        set statusline+=\ [%{getcwd()}]          " Current dir
        set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info

    endif

    set linespace=0                 " No extra spaces between rows, only available for GUI vim
    set number                      " Line numbers on
    set showmatch                   " Show matching brackets/parenthesis
    set winminheight=0              " Windows can be 0 line high
    set ignorecase                  " Case insensitive search
    set smartcase                   " Case sensitive when uc present
    set wildmode=longest,full       " Command <Tab> completion, list matches, then longest common part, then all.
    set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
    set scrolljump=5                " Lines to scroll when cursor leaves screen
    set scrolloff=3                 " Minimum lines to keep above and below cursor
    set foldenable                  " Auto fold code
    set list
    set signcolumn=yes
    set listchars=tab:›\ ,trail:•,extends:+,nbsp:. " Highlight problematic whitespace
" }

" Formatting {
"    set nowrap                     " Do not wrap long lines
    set shiftwidth=4                " Use indents of 4 spaces
    set tabstop=4                   " An indentation every eight columns
    set softtabstop=4               " Let backspace delete indent
    set nojoinspaces                " Prevents inserting two spaces after punctuation on a join (J)
    set splitright                  " Puts new vsplit windows to the right of the current
    set splitbelow                  " Puts new split windows to the bottom of the current
    set expandtab

    " Autoindent according to filetypes
    set cindent
    set cinoptions=g-1,:0,(0,w0
" }

