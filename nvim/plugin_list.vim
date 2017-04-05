" Plugin manager
if &compatible
  set nocompatible
endif
execute 'set runtimepath+='.g:dein_path

if dein#load_state(expand(g:plugin_path))
    call dein#begin(expand(g:plugin_path))

    " Core plugins
    call dein#add('Shougo/dein.vim')
    call dein#add('haya14busa/dein-command.vim')
    call dein#add('Shougo/denite.nvim')

    " Theme
    call dein#add('nanotech/jellybeans.vim')

    " Completion support
    call dein#add('Shougo/deoplete.nvim')
    call dein#add('Shougo/neoinclude.vim')
    call dein#add('zchee/deoplete-jedi', 
    		\ { 'on_ft': 'python' })

    " Enhancement
    call dein#add('Konfekt/FastFold')
    call dein#add('tmux-plugins/vim-tmux-focus-events')
    call dein#add('t9md/vim-choosewin')

    " GUI relative
    call dein#add('ryanoasis/vim-devicons')
    call dein#add('vim-airline/vim-airline')
    call dein#add('itchyny/vim-cursorword')
    call dein#add('airblade/vim-gitgutter')

    " Others
    call dein#add('majutsushi/tagbar')

    " Here we use nerdtree, vimfiler currently not support denite
    call dein#add('scrooloose/nerdtree',
    		\ { 'on_cmd': ['NERDTreeToggle','NERDTree'] })
    call dein#add('ivalkeen/nerdtree-execute',
    		\ { 'on_source': 'nerdtree' })
    call dein#add('Xuyuanp/nerdtree-git-plugin',
    		\ { 'on_source': 'nerdtree' })

    call dein#end()
    call dein#save_state()
endif

