require('nvim-tree').setup {
  -- disables netrw completely, 1 by default
  disable_netrw       = true,
  -- hijack netrw window on startup
  hijack_netrw        = true,
  -- opens the tree when changing/opening a new tab if the tree wasn't previously opened
  open_on_tab         = false,
  -- hijack the cursor in the tree to put it at the start of the filename
  hijack_cursor       = false,
  -- updates the root directory of the tree on `DirChanged` (when your run `:cd` usually)
  update_cwd          = true,     -- false by default
  -- show lsp diagnostics in the signcolumn
  diagnostics = {
    enable = false,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    }
  },
  -- update the focused file on `BufEnter`, un-collapses the folders recursively until it finds the file
  update_focused_file = {
    -- enables the feature
    enable      = false,
    -- update the root directory of the tree to the one of the folder containing the file if the file is not under the current root directory
    -- only relevant when `update_focused_file.enable` is true
    update_cwd  = false,
    -- list of buffer names / filetypes that will not update the cwd if the file isn't found under the current root directory
    -- only relevant when `update_focused_file.update_cwd` is true and `update_focused_file.enable` is true
    ignore_list = {}
  },
  -- configuration options for the system open command (`s` in the tree by default)
  system_open = {
    -- the command to run this, leaving nil should work in most cases
    cmd  = nil,
    -- the command arguments as a list
    args = {}
  },

  view = {
    -- width of the window, can be either a number (columns) or a string in `%`, for left or right side placement
    width = 30,
    -- side of the tree, can be one of 'left' | 'right' | 'top' | 'bottom'
    side = 'left',
    -- if true the tree will resize itself after opening a file
    relativenumber = true,
    mappings = {
      -- custom only false will merge the list with the default mappings
      -- if true, it will only use your list to set the mappings
      custom_only = false,
      -- list of mappings to set on the tree manually
      list = {}
    },
  },

  actions = {
    open_file = {
      resize_window = true,
    },
  },

  filters = {
    -- 0 by default, this option hides files and folders starting with a dot `.`
    dotfiles = true,
    -- empty by default
    custom = { '.git', 'node_modules', '.cache' }
  },

  git = {
    -- 0 by default
    ignore = false,
  }
}

-- left by default
vim.api.nvim_set_var('nvim_tree_side', 'left')
-- 30 by default, can be width_in_columns or 'width_in_percent%'
vim.api.nvim_set_var('nvim_tree_width', 40)
-- empty by default, don't auto open tree on specific filetypes.
vim.api.nvim_set_var('nvim_tree_auto_ignore_ft', { 'startify', 'dashboard' })
-- 0 by default, closes the tree when you open a file
vim.api.nvim_set_var('nvim_tree_quit_on_open', 1)
-- 0 by default, this option shows indent markers when folders are open
vim.api.nvim_set_var('nvim_tree_indent_markers', 1) 
-- 0 by default, will enable file highlight for git attributes (can be used without the icons).
vim.api.nvim_set_var('nvim_tree_git_hl', 1)
-- 0 by default, will enable folder and file icon highlight for opened files/directories.
vim.api.nvim_set_var('nvim_tree_highlight_opened_files', 1)
-- This is the default. See :help filename-modifiers for more options
vim.api.nvim_set_var('nvim_tree_root_folder_modifier', ':~')
-- 0 by default, append a trailing slash to folder names
vim.api.nvim_set_var('nvim_tree_add_trailing', 1)
-- 0 by default, compact folders that only contain a single folder into one node in the file tree
vim.api.nvim_set_var('nvim_tree_group_empty', 1)
-- 0 by default, will disable the window picker.
vim.api.nvim_set_var('nvim_tree_disable_window_picker', 1)
-- one space by default, used for rendering the space between the icon and the filename.
-- Use with caution, it could break rendering if you set an empty string depending on your font.
vim.api.nvim_set_var('nvim_tree_icon_padding', ' ')
-- defaults to ' ➛ '. used as a separator between symlinks' source and target.
vim.api.nvim_set_var('nvim_tree_symlink_arrow', ' >> ')
-- 0 by default, will change cwd of nvim-tree to that of new buffer's when opening nvim-tree.
vim.api.nvim_set_var('nvim_tree_respect_buf_cwd', 1)

vim.api.nvim_set_var('nvim_tree_window_picker_exclude', {
  filetype = {
    'packer',
    'qf'
  },
  buftype = {
    'terminal'
  }
})

-- Dictionary of buffer option names mapped to a list of option values that
-- indicates to the window picker that the buffer's window should not be
-- selectable.

-- List of filenames that gets highlighted with NvimTreeSpecialFile
vim.api.nvim_set_var('nvim_tree_special_files', { ['README.me'] = 1, ['Makefile'] = 1, ['MAKEFILE'] = 1 })
vim.api.nvim_set_var('nvim_tree_show_icons', {
  git = 1,
  folders = 1,
  files = 1,
  folder_arrows = 1,
})

-- If 0, do not show the icons for one of 'git' 'folder' and 'files'
-- 1 by default, notice that if 'files' is 1, it will only display
-- if nvim-web-devicons is installed and on your runtimepath.
-- if folder is 1, you can also tell folder_arrows 1 to show small arrows next to the folder icons.
-- but this will not work when you set indent_markers (because of UI conflict)

-- default will show icon by default if no icon is provided
-- default shows no icon by default
vim.api.nvim_set_var('nvim_tree_icons', {
  default = '',
  symlink = '',
  git = {
    unstaged = "✗",
    staged = "✓",
    unmerged = "",
    renamed = "➜",
    untracked = "★",
    deleted = "",
    ignored = "◌",
  },
  folder =  {
    arrow_open = "",
    arrow_closed = "",
    default = "",
    open = "",
    empty = "",
    empty_open = "",
    symlink = "",
    symlink_open = "",
  },
  lsp = {
    hint = "",
    info = "",
    warning = "",
    error = "",
  }
})

-- vim.api.nvim_set_keymap('n', '<leader>`', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
-- nnoremap <leader>r :NvimTreeRefresh<CR>
-- nnoremap <leader>n :NvimTreeFindFile<CR>

vim.api.nvim_command('set termguicolors')
-- vim.api.nvim_command('highlight NvimTreeFolderIcon guibg=blue')
