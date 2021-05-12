" User settings
let g:dein_path = "~/.config/nvim/plugins/repos/github.com/Shougo/dein.vim"
let g:plugin_path="~/.config/nvim/plugins"

let g:undo_dir="~/.config/nvim/tmp_files/undo_cache"
let g:backup_dir="~/.config/nvim/tmp_files/backup_files"
let g:swap_dir="~/.config/nvim/tmp_files/swap_files"
let g:dein_cache_dir="~/.config/nvim/tmp_files/dein_cache"
let g:neoyank_file="~/.config/nvim/tmp_files/denite_files/yankring.txt"
let g:neomru_dir="~/.config/nvim/tmp_files/denite_files"

" For dein to install plugins
source $HOME/.config/nvim/plugin_list.vim

" For vim's basic settings
source $HOME/.config/nvim/basic_settings.vim

source $HOME/.config/nvim/file_formatting.vim

" Configure plugins
source $HOME/.config/nvim/plugin_settings.vim

" Import key bindings.
source $HOME/.config/nvim/key_mappings.vim

" Set the color scheme
let g:jellybeans_overrides = {
\    'background': { 'ctermbg': 'none', '256ctermbg': 'none' },
\    'ColorColumn': { 'guibg': '303030' },
\}
if has('termguicolors') && &termguicolors
    let g:jellybeans_overrides['background']['guibg'] = 'none'
endif
colorscheme  jellybeans

