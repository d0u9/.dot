local opts = {
  integrations = {
    blink_cmp = true,
    gitsigns = true,
    nvimtree = true,
    treesitter = true,
    illuminate = true,
    fzf = true,
    -- Also styles outline.nvim: the group defines `OutlineCurrent`.
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
