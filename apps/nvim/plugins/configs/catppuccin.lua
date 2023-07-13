local opts = {
  integrations = {
    cmp = true,
    gitsigns = true,
    nvimtree = true,
    treesitter = true,
    illuminate = true,
    telescope = {
      enabled = true,
      -- style = "nvchad"
    },
    symbols_outline = true,
    navic = {
      enabled = true,
      custom_bg = "NONE", -- "lualine" will set background to mantle
    },
    -- notify = false,
    -- mini = false,
  }
}

require("catppuccin").setup(opts)
