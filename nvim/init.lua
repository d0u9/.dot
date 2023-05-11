-- init.lua
-- User settings
function script_path()
  return debug.getinfo(2, "S").source:sub(2):match("(.*/)")
end

function init_lua_package_path(config_dir)
  local dirs = {
    "/init",
    "/plugins",
    "/key_mapping"
  }

  for _, dir in ipairs(dirs) do
    vim.opt.packpath:append(config_dir .. dir)
  end

end

-- Basic setings
_G.CONFIG_DIR = script_path()


vim.opt.runtimepath:append(_G.CONFIG_DIR .. '/plugins/pack/packer/start/packer.nvim')

-- Used for searching packages (vim plugins)
vim.opt.packpath:append(_G.CONFIG_DIR .. 'plugins')

vim.g.undo_dir          = _G.CONFIG_DIR .. '~/.config/nvim/tmp_files/undo_cache'
vim.g.backup_dir        = _G.CONFIG_DIR .. '~/.config/nvim/tmp_files/backup_files'
vim.g.swap_dir          = _G.CONFIG_DIR .. '~/.config/nvim/tmp_files/swap_files'
vim.g.dein_cache_dir    = _G.CONFIG_DIR .. '~/.config/nvim/tmp_files/dein_cache'
vim.g.neoyank_file      = _G.CONFIG_DIR .. '~/.config/nvim/tmp_files/denite_files/yankring.txt'
vim.g.neomru_dir        = _G.CONFIG_DIR .. '~/.config/nvim/tmp_files/denite_files'

-- `package.path` is used to search lub modules.
init_lua_package_path(_G.CONFIG_DIR)

-- nvim plugins to be installed.
require('plugins')

-- nvim's basic settings
vim.cmd('source' .. _G.CONFIG_DIR .. '/basic_settings.vim')

-- vimscript key mappings
vim.cmd('source' .. _G.CONFIG_DIR .. '/key_mappings.vim')

-- nvim's file format
vim.cmd('source' .. _G.CONFIG_DIR .. '/file_formatting.vim')

-- lua plugin settings
require('plugin_settings')

-- vimscript plugin settings
vim.cmd('source' .. _G.CONFIG_DIR .. '/plugin_settings.vim')

-- vimscript key mappings
vim.cmd('source' .. _G.CONFIG_DIR .. '/plugin_key_mappings.vim')
