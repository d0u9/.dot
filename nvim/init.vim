" @author: Douglas Su

call plug#begin('~/.dot/nvim/plugged')

" Plugin tables
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer', 'for': ['c', 'cpp', 'python'] }
Plug 'bling/vim-airline'
Plug 'scrooloose/nerdcommenter'
Plug 'airblade/vim-gitgutter'
Plug 'majutsushi/tagbar'

" Add plugins to &runtimepath
call plug#end()

" General settings {
	set background=dark	

	filetype plugin indent on	" Automatically detect file types.
	syntax on			" Syntax highlighting
	set mousehide			" Hide the mouse cursor while typing


	" Share content with the system's clipborad
	if has('clipboard')
		if has('unnamedplus')	" When possible use + register for copy-paste
			set clipboard=unnamed,unnamedplus
		else			" On mac and Windows, use * register for copy-paste
			set clipboard=unnamed
		endif
	endif

	set shortmess+=filmnrxoOtT	" Avoiding the 'Hit ENTER to continue' prompts
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

	set backup                  " Backups are nice ...
	if has('persistent_undo')
		set undodir=~/.config/nvim/undodir
		set undofile                " So is persistent undo ...
		set undolevels=1000         " Maximum number of changes that can be undone
		set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
	endif

	" http://vim.wikia.com/wiki/Remove_swap_and_backup_files_from_your_working_directory
	set backupdir=./.backup,~/.vim/backup,/tmp
	set directory=.,./.backup,/tmp

	" set UTF-8 encoding
	set fileencoding=utf-8
	scriptencoding utf-8
" }

" Vim UI {

	" Compatibility for Terminal
	let g:solarized_termtrans=1
	let g:solarized_termcolors=256
	let g:solarized_contrast="normal"
	let g:solarized_visibility="normal"

	" Set the color scheme
	set t_Co=256
	colorscheme solarized
	
	set showmode                    " Display the current mode

	" Highligh the column 80
	set colorcolumn=80

	" Highlight current line and column
	set cursorline
	set cursorcolumn

	highlight clear SignColumn      " SignColumn should match background
	highlight clear LineNr          " Current line number row will have same background color in relative mode

	set ruler                   	" Show the ruler
	set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " A ruler on steroids
	set showcmd                 	" Show partial commands in status line and
					" Selected characters/lines in visual mode

	if has('statusline')

		" Broken down into easily includeable segments
		set statusline=%<%f\                     " Filename
		set statusline+=%w%h%m%r                 " Options
		if !exists('g:override_spf13_bundles')
			set statusline+=%{fugitive#statusline()} " Git Hotness
		endif
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
	set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.
	set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
	set scrolljump=5                " Lines to scroll when cursor leaves screen
	set scrolloff=3                 " Minimum lines to keep above and below cursor
	set foldenable                  " Auto fold code
	set list
	set listchars=tab:›\ ,trail:•,extends:+,nbsp:. " Highlight problematic whitespace
" }

" Formatting {
	set nowrap                      " Do not wrap long lines
	set shiftwidth=8                " Use indents of 4 spaces
	set tabstop=8                   " An indentation every eight columns
	set softtabstop=8               " Let backspace delete indent
	set nojoinspaces                " Prevents inserting two spaces after punctuation on a join (J)
	set splitright                  " Puts new vsplit windows to the right of the current
	set splitbelow                  " Puts new split windows to the bottom of the current

" }

" Key (re)Mappings {
	" Set leader key
	let mapleader=","

	" Easier moving in tabs and windows
	" The lines conflict with the default digraph mapping of <C-K>
	map <C-J> <C-W>j<C-W>_
        map <C-K> <C-W>k<C-W>_
        map <C-L> <C-W>l<C-W>_
        map <C-H> <C-W>h<C-W>_

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

	" Some helpers to edit mode
	" http://vimcasts.org/e/14
	cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
	map <leader>ew :e %%
	map <leader>es :sp %%
	map <leader>ev :vsp %%
	map <leader>et :tabe %%

	" Adjust viewports to the same size
	map <Leader>= <C-w>=

	" Map <Leader>ff to display all lines with keyword under cursor
	" and ask which one to jump to
	nmap <Leader>ff [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>

	" Easier horizontal scrolling
	map zl zL
	map zh zH
" }


" Vim-airline {
	let g:airline_powerline_fonts = 1
	let g:airline_theme = 'badwolf'

	" For patched power-line fonts
	if !exists('g:airline_symbols')
		let g:airline_symbols = {}
	endif
	let g:airline_symbols.space = "\ua0"

	let g:airline#extensions#tabline#enabled = 1
	let g:airline#extensions#tabline#left_sep = ' '
	let g:airline#extensions#tabline#left_alt_sep = '|'
" }

" YCM {

	let g:ycm_enable_diagnostic_signs = 0
	let g:ycm_autoclose_preview_window_after_insertion = 1
	let g:ycm_global_ycm_extra_conf = '~/.dot/nvim/plugged/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
	let g:ycm_extra_conf_globlist = ['~/.dot/nvim/plugged/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py']

" }

" Vim-airline {
	let g:airline_powerline_fonts = 1
	let g:airline_theme = 'badwolf'

	" For patched power-line fonts
	if !exists('g:airline_symbols')
		let g:airline_symbols = {}
	endif
	let g:airline_symbols.space = "\ua0"

	let g:airline#extensions#tabline#enabled = 1
	let g:airline#extensions#tabline#left_sep = ' '
	let g:airline#extensions#tabline#left_alt_sep = '|'
" }

" nerdcommenter {
	
" }

" vim-gitgutter {
	" Disable all the git-gutter key bindings
	let g:gitgutter_map_keys = 0
	" Show the gutter always
	let g:gitgutter_sign_column_always = 1
" }

" tagbar {
	nmap <C-t> :TagbarToggle<CR>
" }

