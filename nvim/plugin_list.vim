" Plugin manager
if &compatible
  set nocompatible
endif
execute 'set runtimepath+='.g:dein_path

if dein#load_state(expand(g:plugin_path))
    call dein#begin(expand(g:plugin_path), expand('<sfile>:p'))

    " Core plugins
    call dein#add('Shougo/dein.vim')
    call dein#add('haya14busa/dein-command.vim')
    call dein#add('Shougo/denite.nvim')
    call dein#add('Shougo/neomru.vim')

    " Theme
    call dein#add('nanotech/jellybeans.vim')

    " Completion support
    call dein#add('Shougo/deoplete.nvim')
    call dein#add('Shougo/neoinclude.vim')
    call dein#add('zchee/deoplete-jedi', 
            \ { 'on_ft': 'python' })
    call dein#add('tweekmonster/deoplete-clang2',
            \ { 'on_ft': ['c', 'cpp'] })

    " Enhancement
    call dein#add('Konfekt/FastFold')
    call dein#add('tmux-plugins/vim-tmux-focus-events')
    call dein#add('t9md/vim-choosewin')
    call dein#add('mbbill/undotree',
            \ { 'on_cmd': 'UndotreeToggle' })

    " GUI relative
    call dein#add('ryanoasis/vim-devicons')
    call dein#add('vim-airline/vim-airline')
    call dein#add('itchyny/vim-cursorword')
    call dein#add('airblade/vim-gitgutter')

    " Others
    call dein#add('majutsushi/tagbar')
    call dein#add('scrooloose/nerdcommenter')
    call dein#add('tpope/vim-fugitive',
            \ { 'on_cmd': ['Gstatus', 'Gdiff'] })

    " Here we use nerdtree, vimfiler currently not support denite
    call dein#add('scrooloose/nerdtree',
            \ { 'on_cmd': ['NERDTreeToggle','NERDTree'] })
    call dein#add('ivalkeen/nerdtree-execute',
            \ { 'on_source': 'nerdtree' })
    call dein#add('Xuyuanp/nerdtree-git-plugin',
            \ { 'on_source': 'nerdtree' })

    " For better cpp file hightlight
    call dein#add('octol/vim-cpp-enhanced-highlight',
            \ { 'on_ft': ['c', 'cpp'] })
    " Draw tables in vim
    call dein#add('dhruvasagar/vim-table-mode',
            \ { 'on_cmd': 'TableModeToggle' })
    " For hex editing
    call dein#add('Shougo/vinarise.vim')

    call dein#end()
    call dein#save_state()
endif

