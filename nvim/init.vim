" @author: Douglas Su

call plug#begin('~/.dot/nvim/plugged')

" Plugin tables
Plug 'scrooloose/nerdcommenter'
Plug 'airblade/vim-gitgutter'
Plug 'majutsushi/tagbar'
Plug 'jeetsukumaran/vim-buffergator'
Plug 'bling/vim-bufferline'
Plug 'rking/ag.vim'
Plug 'mbbill/undotree'
Plug 'tpope/vim-fugitive'
Plug 'Valloric/ListToggle'
Plug 'd0u9/cscope.vim'
Plug 'Shougo/vinarise.vim'

Plug 'bling/vim-airline'
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'vim-airline/vim-airline-themes'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'scrooloose/nerdtree'
Plug 'ivalkeen/nerdtree-execute'
Plug 'Xuyuanp/nerdtree-git-plugin'
\ | Plug 'ryanoasis/vim-devicons'


Plug 'rizzatti/dash.vim', { 'for': ['c', 'cpp', 'python', 'php'] }
Plug 'octol/vim-cpp-enhanced-highlight', { 'for': ['c', 'cpp'] }
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer', 'for': ['c', 'cpp', 'css', 'html'] }
Plug 'vivien/vim-linux-coding-style', { 'for': ['c'] }

Plug 'dhruvasagar/vim-table-mode', { 'on': 'TableModeToggle' }
Plug 'wesQ3/vim-windowswap'
Plug 'tpope/vim-unimpaired'
Plug 'davidhalter/jedi-vim', { 'for': ['python'] }


" Add plugins to &runtimepath
call plug#end()

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

" Custom settings {
	if LINUX()
		let g:python3_host_prog = $HOME . '/.pyenv/versions/3.5.2/bin/python3.5'
		let g:ycm_server_python_interpreter = $HOME . '/.pyenv/versions/3.5.2/bin/python3.5'
	endif
" }


" General settings {
	set background=dark

	filetype plugin indent on	" Automatically detect file types.
	syntax on			" Syntax highlighting
	set mousehide			" Hide the mouse cursor while typing


	" Share content with the system's clipborad
	set clipboard+=unnamedplus

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
		set undodir=~/.config/nvim/cache_dir/undo_cache
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
"	set nowrap                      " Do not wrap long lines
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

	" let the code style of .h file act as .c not .cpp
	" the default is cpp
	let c_syntax_for_h = 1

	autocmd Filetype html setlocal ts=2 sw=2 expandtab
	autocmd Filetype css setlocal ts=2 sw=2 expandtab
	"autocmd Filetype cpp setlocal ts=4 sw=4 expandtab
	autocmd Filetype c setlocal ts=8 sw=8 sts=8 noexpandtab nolist
	autocmd Filetype vim setlocal ts=8 sw=8 sts=8 noexpandtab
" }

" Key (re)Mappings {
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

	" Some helpers to edit mode
	" http://vimcasts.org/e/14
	cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
	nmap <leader>ew :e %%
	nmap <leader>es :sp %%
	nmap <leader>ev :vsp %%
	nmap <leader>et :tabe %%
	nmap <leader>eb : %%


	" Map <Leader>ff to display all lines with keyword under cursor
	" and ask which one to jump to
	nmap <Leader>ff [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>

	" Easier horizontal scrolling
	map zl zL
	map zh zH

	" Windows resizeing
	nnoremap <silent> <Leader>w' :exe "resize " . (winheight(0) * 3/2)<CR>
	nnoremap <silent> <Leader>w; :exe "resize " . (winheight(0) * 2/3)<CR>

	nnoremap <silent> <Leader>w] :exe "vertical resize -" . (winheight(0) * 1/2)<CR>
	nnoremap <silent> <Leader>w[ :exe "vertical resize +" . (winheight(0) * 1/2)<CR>

	" Adjust viewports to the same size
	map <Leader>w= <C-w>=

	" Go back to previous window
	"map <Leader>wp <C-w>p


	" Line number toggle {
		let g:relativemode = 0
		" Enables relative numbers.
		function! EnableRelativeNumbers()
			set number
			set relativenumber
		endfunc

		" Disables relative numbers.
		function! DisableRelativeNumbers()
			set number
			set norelativenumber
		endfunc

		" NumberToggle toggles between relative and absolute line numbers
		function! NumberToggle()
			if(&relativenumber == 1)
				call DisableRelativeNumbers()
				let g:relativemode = 0
			else
				call EnableRelativeNumbers()
				let g:relativemode = 1
			endif
		endfunc

		map <silent> <leader>tl :call NumberToggle()<CR>
	" }

	" Re-generate and load cscope lib {
		function! FindCscopeDB()
			execute "echo \"Regenerate and load cscop db.\""
			execute "silent !cscope -Rbq"

			redir => cs_file
			silent cscope show
			redir END

			if cs_file =~ "^no"
				execute "silent cscope add cscope.out"
			else
				execute "silent cscope reset"
			endif
		endfunc

		map <silent> <F9> :call FindCscopeDB()<CR>
	"}
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
	let g:airline#extensions#tabline#fnamemod = ':t'
" }


" YCM {
	let g:ycm_python_binary_path = 'python'
	let g:ycm_enable_diagnostic_signs = 0
	let g:ycm_autoclose_preview_window_after_insertion = 1
	let g:ycm_global_ycm_extra_conf = '~/.config/nvim/ycm_extra_conf.py'
	let g:ycm_extra_conf_globlist = ['~/.config/nvim/ycm_extra_conf.py']

	nnoremap <leader>jr :YcmDiags<CR>
	nnoremap <leader>jh :YcmCompleter GoToInclude<cr>
	nnoremap <leader>jd :YcmCompleter GoTo<cr>
	nnoremap <leader>jl :YcmCompleter GoToDeclaration<cr>
	nnoremap <leader>jf :YcmCompleter GoToDefinition<cr>
	nnoremap <leader>jx :YcmCompleter FixIt<cr>
	nnoremap <leader>jp :YcmCompleter GetParent<cr>
	nnoremap <leader>jt :YcmCompleter GetType<cr>
	nnoremap <leader>jo :YcmCompleter GetDoc<cr>

	let g:ycm_filetype_blacklist = {
	      \ 'tagbar' : 1,
	      \ 'qf' : 1,
	      \ 'notes' : 1,
	      \ 'markdown' : 1,
	      \ 'unite' : 1,
	      \ 'text' : 1,
	      \ 'vimwiki' : 1,
	      \ 'pandoc' : 1,
	      \ 'infolog' : 1,
	      \ 'mail' : 1,
	      \ 'gitcommit' : 1
	      \}
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
	nnoremap <silent> <F4> :TagbarToggle<CR>
" }


" CtrlP {
	" Setup some default ignores
	let g:ctrlp_custom_ignore = {
				\ 'dir':  '\v[\/](\.(git|hg|svn)|\_site)$',
				\ 'file': '\v\.(exe|so|dll|class|png|jpg|jpeg|doc|docx|pdf)$',
				\}

	" Use the nearest .git directory as the cwd
	" This makes a lot of sense if you are working on a project that is in version
	" control. It also supports works with .svn, .hg, .bzr.
	let g:ctrlp_working_path_mode = 'r'

	" Use a leader instead of the actual named binding
	nmap <leader>p :CtrlP<cr>

	" Easy bindings for its various modes
	nmap <leader>bb :CtrlPBuffer<cr>
	nmap <leader>bm :CtrlPMixed<cr>
	nmap <leader>bs :CtrlPMRU<cr>
" }

" Speed Up CtrlP {
"
	let g:ctrlp_cache_dir = $HOME . '/.config/nvim/cache_dir/ctrlp_cache'
	if executable('ag')
	let file_type_to_be_ignored = 'exe|so|dll|class|png|jpg|jpeg|doc|docx|pdf|icon|gif'
	let g:ctrlp_user_command = 'ag %s -i -l --nocolor --depth 5 -g "" '
			\ . '--ignore "' . file_type_to_be_ignored . '"'
	endif
	let g:ctrlp_clear_cache_on_exit = 1
" }

" vim-buffergator {
	" Use the right side of the screen
	let g:buffergator_viewport_split_policy = 'B'

	" I want my own keymappings...
	let g:buffergator_suppress_keymaps = 1

	" Looper buffers
	"let g:buffergator_mru_cycle_loop = 1

	" Go to the previous buffer open
        " Use [b instead
	"nmap <leader>bj :BuffergatorMruCyclePrev<cr>

	" Go to the next buffer open
        " Use ]b instead
	"nmap <leader>bk :BuffergatorMruCycleNext<cr>

	" View the entire list of buffers open
	nmap <leader>bl :BuffergatorOpen<cr>

	" Shared bindings from Solution #1 from earlier
	nmap <leader>bt :enew<cr>
	nmap <leader>bq :bp <BAR> bd #<cr>
" }


" Ag {
" }

" undotree {
	nmap <leader>ut :UndotreeToggle<cr>
	let g:undotree_SplitWidth = 50
	let g:undotree_WindowLayout = 2
" }

" fugitive {
	set diffopt+=vertical
" }

" ListToggle {
	let g:lt_height = 18
" }

" vinarise {

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

