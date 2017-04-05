if &compatible
  set nocompatible
endif
set runtimepath+=~/.dot/nvim/plugins/repos/github.com/Shougo/dein.vim

if dein#load_state(expand('~/.dot/nvim/plugins'))
  call dein#begin(expand('~/.dot/nvim/plugins'))

  call dein#add('Shougo/dein.vim')

  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable
