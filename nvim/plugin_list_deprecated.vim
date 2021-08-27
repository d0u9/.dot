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

    " Nvim 0.5 Only
    call dein#add('neovim/nvim-lspconfig')
    call dein#add('hrsh7th/nvim-cmp')

    call dein#add('hrsh7th/cmp-nvim-lsp')
    call dein#add('saadparwaiz1/cmp_luasnip')
    call dein#add('L3MON4D3/LuaSnip')
    call dein#add('nvim-lua/plenary.nvim')
    call dein#add('nvim-telescope/telescope.nvim')
    call dein#add('arcticicestudio/nord-vim')

    " Autocompletion
    call dein#add('autozimu/LanguageClient-neovim', {
            \ 'rev': 'next',
            \ 'build': 'bash install.sh',
            \ 'on_ft': ['go', 'rust'],
            \ })

    " Completion support
    call dein#add('Shougo/neoinclude.vim')
    call dein#add('Shougo/deoplete.nvim',
            \ { 'name': 'deoplete' })
    "call dein#add('Shougo/deoplete-clangx',
    "        \ { 'on_ft': ['c', 'cpp'],
    "        \   'depends': 'deoplete' })
    " call dein#add('deoplete-plugins/deoplete-go',
    "         \ { 'on_ft': ['go'],
    "         \   'depends': 'deoplete',
    "         \   'build': 'make' })
    call dein#add('Shougo/neco-vim',
            \ { 'on_ft': 'vim',
            \   'depends': 'deoplete' })
    "call dein#add('davidhalter/jedi-vim',
    "        \ { 'on_ft': 'python'})

    " Enhancement
    call dein#add('Konfekt/FastFold')
    call dein#add('tmux-plugins/vim-tmux-focus-events')
    call dein#add('t9md/vim-choosewin')
    call dein#add('Shougo/neoyank.vim')
    call dein#add('mbbill/undotree', {
            \ 'on_cmd': 'UndotreeToggle',
            \ 'on_ft': ['nerdtree'],
            \ })
    call dein#add('Thyrum/vim-stabs')


    " GUI relative
    call dein#add('ryanoasis/vim-devicons')
    call dein#add('vim-airline/vim-airline',
            \ { 'rev': 'f7cbf8c' })
    call dein#add('itchyny/vim-cursorword')
    call dein#add('airblade/vim-gitgutter')

    " Others
    call dein#add('majutsushi/tagbar')
    call dein#add('scrooloose/nerdcommenter')
    call dein#add('tpope/vim-fugitive')

    " Here we use nerdtree, vimfiler currently not support denite
    call dein#add('scrooloose/nerdtree',
            \ { 'on_cmd': ['NERDTreeToggle','NERDTree'] })
    call dein#add('ivalkeen/nerdtree-execute',
            \ {'depends': 'nerdtree' })
    call dein#add('Xuyuanp/nerdtree-git-plugin',
            \ { 'depends': 'nerdtree' })

    " For better cpp file hightlight
    call dein#add('octol/vim-cpp-enhanced-highlight',
            \ { 'on_ft': ['c', 'cpp'] })
    " Draw tables in vim
    call dein#add('dhruvasagar/vim-table-mode',
            \ { 'on_cmd': 'TableModeToggle' })
    " For better markdown highlight
    call dein#add('plasticboy/vim-markdown',
            \ { 'on_ft': 'markdown' })
    " For hex editing
    call dein#add('Shougo/vinarise.vim',
            \ { 'on_idle': 1 })
    " An ASCII box drawing plugin
    call dein#add('gyim/vim-boxdraw',
            \ { 'on_idle': 1 })

    call dein#end()
    call dein#save_state()
endif

autocmd FileType python let b:deoplete_disable_auto_complete = 1

