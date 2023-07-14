local opts = {
  disable_netrw       = true,
  -- updates the root directory of the tree on `DirChanged` (when your run `:cd` usually)
  sync_root_with_cwd  = true,     -- false by default
  -- configuration options for the system open command (`s` in the tree by default)
  view = {
    -- width of the window, can be either a number (columns) or a string in `%`, for left or right side placement
    width = {
      min = "10%",
    },
    side = 'left',
    relativenumber = true,
  },
  actions = {
    change_dir = {
      enable = true,
      global = true,
      restrict_above_cwd = false,
    },
    open_file = {
      quit_on_open = true,
      resize_window = true,
    },
  },
  filters = {
    -- 0 by default, this option hides files and folders starting with a dot `.`
    dotfiles = true,
    -- empty by default
    custom = { '\\.git', 'node_modules', '\\.cache' }
  },
  git = {
    -- 0 by default
    ignore = false,
  },
}

local on_attach = function (bufnr)
  local api = require('nvim-tree.api')

  api.config.mappings.default_on_attach(bufnr)
  require("config.keymaps").nvim_tree_keymap()
end

opts.on_attach = on_attach
require('nvim-tree').setup(opts)

