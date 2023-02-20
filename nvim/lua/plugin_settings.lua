local function setup_if_has(cb, lib, ...)
  local status, l = pcall(require, lib)
  if (not status) then return end
  for i = 1, select('#', ...) do
    local findit = pcall(require, select(i, ...))
    if (not findit) then return end
  end

  cb()
end

---------- nvim-lsconfig -----------
local function config_nvim_lsconfig()
  require('lspconfig').gopls.setup{
    cmd = {"gopls", "serve"},
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
      },
    },
  }

  require('lspconfig').rust_analyzer.setup{
    settings = {
      ["rust-analyzer"] = {
        assist = {
          importGranularity = "module",
          importPrefix = "by_self",
        },
        diagnostics = {
          disabled = {
            "inactive-code",
          }
        },
        cargo = {
          loadOutDirsFromCheck = false
        },
        procMacro = {
          enable = true
        },
      }
    }
  }
end
setup_if_has(config_nvim_lsconfig, 'lspconfig')

----------- lspkind-nvim -----------
function config_lspkind_nvim()
  require('lspkind').init({
    -- defines how annotations are shown
    -- default: symbol
    -- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
    mode = 'symbol_text',

    -- default symbol map
    -- can be either 'default' (requires nerd-fonts font) or
    -- 'codicons' for codicon preset (requires vscode-codicons font)
    --
    -- default: 'default'
    preset = 'codicons',

    -- override preset symbols
    --
    -- default: {}
    symbol_map = {
      Text = "",
      Method = "",
      Function = "",
      Constructor = "",
      Field = "ﰠ",
      Variable = "",
      Class = "ﴯ",
      Interface = "",
      Module = "",
      Property = "ﰠ",
      Unit = "塞",
      Value = "",
      Enum = "",
      Keyword = "",
      Snippet = "",
      Color = "",
      File = "",
      Reference = "",
      Folder = "",
      EnumMember = "",
      Constant = "",
      Struct = "פּ",
      Event = "",
      Operator = "",
      TypeParameter = ""
    },
  })
end
setup_if_has(config_lspkind_nvim, 'lspkind')

----------- nvim-tree -----------
function config_nvim_tree()
  require'nvim-tree'.setup {
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
      ignore = true
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

  vim.api.nvim_set_keymap('n', '<leader>`', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
  -- nnoremap <leader>r :NvimTreeRefresh<CR>
  -- nnoremap <leader>n :NvimTreeFindFile<CR>

  vim.api.nvim_command('set termguicolors')
  -- vim.api.nvim_command('highlight NvimTreeFolderIcon guibg=blue')
end
setup_if_has(config_nvim_tree, 'nvim-tree')

----------- nvim-cmp -----------
function config_nvim_cmp()
  local cmp = require('cmp')
  cmp.setup {
    preselect = cmp.PreselectMode.None,
    snippet = {
      expand = function(args)
        vim.fn['vsnip#anonymous'](args.body)
      end
    },
    sorting = {
      comparators = {
        cmp.config.compare.offset,
        cmp.config.compare.exact,
        cmp.config.compare.score,
        -- cmp.config.compare.kind,
        cmp.config.compare.sort_text,
        cmp.config.compare.length,
        -- cmp.config.compare.order,
      },
    },
    mapping = {
      -- ['<C-p>'] = cmp.mapping.select_prev_item(),
      -- ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-u>'] = cmp.mapping.scroll_docs(-4),
      ['<C-d>'] = cmp.mapping.scroll_docs(4),
      -- ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.close(),
      ['<CR>'] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Insert,
        -- select = true,
      },
      ['<Tab>'] = function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end,
      ['<S-Tab>'] = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end,
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'buffer' },
    },
    formatting = {
      format = function(entry, vim_item)
        -- fancy icons and a name of kind
        vim_item.kind = "      " .. require('lspkind').presets.default[vim_item.kind] .. " " .. vim_item.kind

        -- set a name for each source
        vim_item.menu = ({
          buffer = "[Buffer]",
          nvim_lsp = "[LSP]",
          luasnip = "[LuaSnip]",
          nvim_lua = "[Lua]",
          latex_symbols = "[Latex]",
        })[entry.source.name]
        return vim_item
      end,
    },
  }
end
setup_if_has(config_nvim_cmp, 'cmp', 'lspkind')

----------- nvim-treesitter -----------
function config_nvim_treesitter()
  require('nvim-treesitter.configs').setup {
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
  }
end
setup_if_has(config_nvim_treesitter, 'nvim-treesitter')

----------- telescope -----------
function config_telescope()
  require('telescope').setup{
    defaults = {
      vimgrep_arguments = {
        'rg',
        '--vimgrep',
        '--max-depth',
        '5',
      },
    },
    file_ignore_patterns = {"%.o"},
  }
end
setup_if_has(config_telescope, 'telescope')

----------- kommentary -----------
function config_kommentary()
  vim.g.kommentary_create_default_mappings = false
  require('kommentary.config').configure_language("default", {
    prefer_single_line_comments = true,
  })
end
setup_if_has(config_kommentary, 'kommentary')


----------- rust-tools.nvim -----------
local function config_rust_tools()
  local opts = {
    tools = { -- rust-tools options
      autoSetHints = true,
      inlay_hints = {
        show_parameter_hints = true,
        -- parameter_hints_prefix = "<-",
        -- other_hints_prefix = "=>",
      },
    },

    -- all the opts to send to nvim-lspconfig
    -- these override the defaults set by rust-tools.nvim
    -- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
    server = {
      -- on_attach is a callback called when the language server attachs to the buffer
      -- on_attach = on_attach,
      settings = {
        -- to enable rust-analyzer settings visit:
        -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
        ["rust-analyzer"] = {
          -- enable clippy on save
          checkOnSave = {
            command = "clippy"
          },
        }
      }
    },
  }
  require('rust-tools').setup(opts)
end
setup_if_has(config_rust_tools, 'rust-tools')
