-- init.lua User settings
function init_lua_package_path(config_dir)
  local dirs = {
    '.',
  }

  for _, dir in ipairs(dirs) do
    package.path = package.path .. ';' .. config_dir .. '/' .. dir .. '/?.lua'
  end
end

function init_runtime_dirs(runtime_dir)
  local dirs = {
    'undo',
    'backup',
    'swap',
    'mason',
  }

  for _, dir in ipairs(dirs) do
    path = runtime_dir .. '/' .. dir
    require('lib.utils').ensure_directory_exists(path)
  end

end

function env_prepare(config_dir, runtime_dir)
  -- `package.path` is used to search lub modules.
  init_lua_package_path(_G.CONFIG_DIR)

  -- set up runtime dirs
  init_runtime_dirs(_G.RUNTIME_DIR)
end

-- Basic setings
_G.CONFIG_DIR = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
_G.RUNTIME_DIR = _G.CONFIG_DIR .. '/runtime'
_G.PLUGIN_DIR = _G.RUNTIME_DIR .. '/plugins'
_G.MASON_DIR = _G.RUNTIME_DIR .. '/mason'

-- set up environments preparation for running neovim
env_prepare(_G.CONFIG_DIR, _G.RUNTIME_DIR)

vim.opt.runtimepath:append(_G.PLUGIN_DIR .. '/pack/packer/start/packer.nvim')

-- Used for searching packages (vim plugins)
vim.opt.packpath:append(_G.PLUGIN_DIR)

vim.opt.undodir     = _G.RUNTIME_DIR .. '/undo/'
vim.opt.backupdir   = _G.RUNTIME_DIR .. '/backup_files/'
vim.opt.directory   = _G.RUNTIME_DIR .. '/swap_files/'

-- nvim plugins to be installed.
require('plugins.install')
require('plugins.setting')

-- nvim's basic settings
require('config.vimscripts')

-- nvim's diagostic settings
require('config.diagnostic')

-- lua key mappings
require('config.keymaps')
