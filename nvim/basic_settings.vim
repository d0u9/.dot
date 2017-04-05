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

	filetype plugin indent on	" Automatically detect file types.
	syntax on			" Syntax highlighting
	set mousehide			" Hide the mouse cursor while typing
	set noeol


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
		set undodir=~/.config/nvim/tmp_files/undo_cache
		set undofile                " So is persistent undo ...
		set undolevels=1000         " Maximum number of changes that can be undone
		set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
	endif

	" http://vim.wikia.com/wiki/Remove_swap_and_backup_files_from_your_working_directory
	set backupdir=./.backup,~/.config/nvim/tmp_files/backup_files,/tmp
	set directory=.,./.backup,~/config/nvim/tmp_files/swap_files,tmp

	" set UTF-8 encoding
	set fileencoding=utf-8
	scriptencoding utf-8
" }



