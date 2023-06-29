----------- lualine -----------
function config_lualine()
  require('lualine').setup {
    options = {
      icons_enabled = true,
      theme = 'nord',
      component_separators = { left = '', right = ''},
      section_separators = { left = '', right = '' },
      disabled_filetypes = {
        statusline = {},
        winbar = {},
      },
      ignore_focus = {},
      always_divide_middle = true,
      globalstatus = false,
      refresh = {
        statusline = 1000,
        tabline = 1000,
        winbar = 1000,
      }
    },
    sections = {
      lualine_a = {'mode'},
      lualine_b = {'branch', 'diff', 'diagnostics'},
      lualine_c = {
        {
          'filename',
          file_status = true,
          newfile_status = true,
          path = 4,
          shorting_target = 30,
          symbols = {
            modified = '',  -- f0fe
            readonly = '',  -- f146
            newfile = '',   -- f0c8
            unnamed = '',   -- f096
          }
        }
      },
      lualine_x = {
        'encoding',
        {
          'filetype',
          colored = true,
          icon_only = true,
        },
        {
          'fileformat',
          symbols = {
            unix = '',      -- f17c
            dos = '',       -- f17a
            mac = '',       -- f179
          },
        },
      },
      lualine_y = {'progress'},
      lualine_z = {
        'location',
        {
          'datetime',
          style = "%H:%M",
        }
      }
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {
        {
          'filename',
          path = 3,
          shorting_target = 30,
          symbols = {
            modified = '',  -- f0fe
            readonly = '',  -- f146
            newfile = '',   -- f0c8
            unnamed = '',   -- f096
          },
        }
      },
      lualine_x = {'location'},
      lualine_y = {},
      lualine_z = {},
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {'nvim-tree', 'symbols-outline', 'quickfix'}
  }
end

