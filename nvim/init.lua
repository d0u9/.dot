-- init.lua User settings
function init_lua_package_path(config_dir)
  local dirs = {
    'basic_config',
    'plugin_config',
    'key_mapping',
    'lib',
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
  }

  for _, dir in ipairs(dirs) do
    path = runtime_dir .. '/' .. dir
    ensure_directory_exists(path)
  end

end

function env_prepare(config_dir, runtime_dir)
  -- `package.path` is used to search lub modules.
  init_lua_package_path(_G.CONFIG_DIR)

  require('lib')

  -- set up runtime dirs
  init_runtime_dirs(_G.RUNTIME_DIR)
end

-- Basic setings
_G.CONFIG_DIR = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
_G.RUNTIME_DIR = _G.CONFIG_DIR .. '/' .. 'runtime'

-- set up environments preparation for running neovim
env_prepare(_G.CONFIG_DIR, _G.RUNTIME_DIR)

vim.opt.runtimepath:append(_G.CONFIG_DIR .. 'plugins/pack/packer/start/packer.nvim')

-- Used for searching packages (vim plugins)
vim.opt.packpath:append(_G.CONFIG_DIR .. 'plugins')

vim.opt.undodir     = _G.RUNTIME_DIR .. '/undo/'
vim.opt.backupdir   = _G.RUNTIME_DIR .. '/backup_files/'
vim.opt.directory   = _G.RUNTIME_DIR .. '/swap_files/'

-- nvim plugins to be installed.
require('plugin_install')

-- nvim's basic settings
vim.cmd('source' .. _G.CONFIG_DIR .. '/basic_config/basic_setting.vim')

-- nvim's file format
vim.cmd('source' .. _G.CONFIG_DIR .. '/basic_config/file_formatting.vim')

-- lua plugin settings
require('plugin_setting')

-- vimscript plugin settings
vim.cmd('source' .. _G.CONFIG_DIR .. '/plugin_config/plugin_setting.vim')

-- vimscript key mappings
vim.cmd('source' .. _G.CONFIG_DIR .. '/key_mapping/basic_key_mapping.vim')

-- vimscript key mappings
vim.cmd('source' .. _G.CONFIG_DIR .. '/key_mapping/plugin_key_mappings.vim')


