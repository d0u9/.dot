-- init.lua User settings
local function init_lua_package_path(config_dir)
  local dirs = {
    '.',
  }

  for _, dir in ipairs(dirs) do
    package.path = package.path .. ';' .. config_dir .. '/' .. dir .. '/?.lua'
  end
end

local function init_runtime_dirs(runtime_dir)
  local dirs = {
    'undo',
    'backup_files',
    'swap_files',
    'mason',
  }

  for _, dir in ipairs(dirs) do
    local path = runtime_dir .. '/' .. dir
    require('lib.utils').ensure_directory_exists(path)
  end

end

local function env_prepare(config_dir, runtime_dir)
  -- `package.path` is used to search lub modules.
  init_lua_package_path(config_dir)

  -- set up runtime dirs
  init_runtime_dirs(runtime_dir)
end

-- Basic setings
_G.CONFIG_DIR = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
_G.RUNTIME_DIR = _G.CONFIG_DIR .. '/runtime'
_G.PLUGIN_DIR = _G.RUNTIME_DIR .. '/plugins'
_G.MASON_DIR = _G.RUNTIME_DIR .. '/mason'
-- lazy.nvim clones every plugin, itself included, under this directory.
_G.LAZY_DIR = _G.PLUGIN_DIR .. '/lazy'
_G.THEME = function()
  return "catppuccin-frappe"
  -- return "catppuccin-macchiato"
end

-- set up environments preparation for running neovim
env_prepare(_G.CONFIG_DIR, _G.RUNTIME_DIR)

-- The leader key has to be set before lazy.nvim loads any plugin, otherwise
-- plugin mappings are bound against the previous leader. `config.keymaps`
-- sets it again so that the two never drift apart.
vim.g.mapleader = ","

require('config.options')
require('config.autocmds')

-- Clone lazy.nvim on first start, then put it on the runtimepath.
local lazy_repo = _G.LAZY_DIR .. '/lazy.nvim'
if not vim.uv.fs_stat(lazy_repo) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazy_repo,
  })
end
vim.opt.runtimepath:prepend(lazy_repo)

vim.opt.undodir     = _G.RUNTIME_DIR .. '/undo/'
vim.opt.backupdir   = _G.RUNTIME_DIR .. '/backup_files/'
vim.opt.directory   = _G.RUNTIME_DIR .. '/swap_files/'

-- nvim plugins to be installed. `plugins.install` returns the lazy.nvim spec;
-- `plugins.setting` configures the plugins lazy has just loaded.
require('lazy').setup(require('plugins.install'), {
  root = _G.LAZY_DIR,
  -- Tracked in git next to the spec, so every host installs the same commits.
  lockfile = _G.CONFIG_DIR .. 'lazy-lock.json',
  install = { colorscheme = { _G.THEME() } },
})
require('plugins.setting')

require('config.colors')

-- nvim's diagostic settings
require('config.diagnostic')

-- lua key mappings
require('config.keymaps')
