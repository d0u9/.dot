-- init.lua
-- User settings

vim.opt.runtimepath = vim.opt.runtimepath + '~/.config/nvim/plugins/pack/packer/start/packer.nvim'
vim.g.plugin_path = '~/.config/nvim/plugins'
vim.opt.packpath = vim.opt.packpath + '~/.config/nvim/plugins'

vim.g.undo_dir = '~/.config/nvim/tmp_files/undo_cache'
vim.g.backup_dir = '~/.config/nvim/tmp_files/backup_files'
vim.g.swap_dir = '~/.config/nvim/tmp_files/swap_files'
vim.g.dein_cache_dir = '~/.config/nvim/tmp_files/dein_cache'
vim.g.neoyank_file = '~/.config/nvim/tmp_files/denite_files/yankring.txt'
vim.g.neomru_dir = '~/.config/nvim/tmp_files/denite_files'

-- nvim plugins to be installed.
require('plugins')

-- nvim's basic settings
vim.cmd('source $HOME/.config/nvim/basic_settings.vim')

-- vimscript key mappings
vim.cmd('source $HOME/.config/nvim/key_mappings.vim')

-- nvim's file format
vim.cmd('source $HOME/.config/nvim/file_formatting.vim')

-- lua plugin settings
require('plugin_settings')

-- vimscript plugin settings
vim.cmd('source $HOME/.config/nvim/plugin_settings.vim')

-- vimscript key mappings
vim.cmd('source $HOME/.config/nvim/plugin_key_mappings.vim')
