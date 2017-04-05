" User settings
let g:dein_path = "~/.config/nvim/plugins/repos/github.com/Shougo/dein.vim"
let g:plugin_path="~/.config/nvim/plugins"

" For dein to install plugins
source $HOME/.config/nvim/plugin_list.vim

" For vim's basic settings
source $HOME/.config/nvim/basic_settings.vim

" Set the color scheme
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set t_Co=256

let g:jellybeans_overrides = {
\    'background': { 'guibg': 'none' },
\    'Delimiter': { 'guibg': 'none' },
\}

colorscheme  jellybeans

" Configure plugins
source $HOME/.config/nvim/plugin_settings.vim
