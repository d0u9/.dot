local navic = require("nvim-navic")

local options = {
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
}

local sections = {
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
}


local inactive_sections = {
  lualine_a = {},
  lualine_b = {},
  lualine_c = {
    {
      'filename',
      path = 3,
      shorting_target = 30,
    }
  },
  lualine_x = {'location'},
  lualine_y = {},
  lualine_z = {},
}

local winbar = {
  lualine_a = {},
  lualine_b = {},
  lualine_x = {},
  lualine_y = {'filename'},
  lualine_z = {},
  lualine_c = {
    "navic",
    color_correction = nil,
    navic_opts = nil
  },
}

local inactive_winbar = {
  lualine_a = {},
  lualine_b = {},
  lualine_x = {},
  lualine_y = {'filename'},
  lualine_z = {},
  lualine_c = {
    "navic",
    color_correction = nil,
    navic_opts = nil
  },
}

local opts = {
  options = options,
  sections = sections,
  inactive_sections = inactive_sections,
  winbar = winbar,
  tabline = {},
  inactive_winbar = inactive_winbar,
  extensions = {'nvim-tree', 'symbols-outline', 'quickfix', 'fugitive'}
}

require('lualine').setup(opts)
