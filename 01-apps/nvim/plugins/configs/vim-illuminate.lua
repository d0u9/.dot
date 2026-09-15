local opts = {
  delay = 100,
  filetypes_denylist = {
    'dirvish',
    'fugitive',
    'NvimTree',
  },
}
require('illuminate').configure(opts)

-- local hicolor = "Visual"
-- local hicolor = "healthError"
local hicolor = "Pmenu"

-- change the highlight style
vim.api.nvim_set_hl(0, "IlluminatedWordText", { link = hicolor })
vim.api.nvim_set_hl(0, "IlluminatedWordRead", { link = hicolor })
vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { link = hicolor })

--- auto update the highlight style on colorscheme change
vim.api.nvim_create_autocmd({ "ColorScheme" }, {
  pattern = { "*" },
  callback = function(ev)
    vim.api.nvim_set_hl(0, "IlluminatedWordText", { link = hicolor })
    vim.api.nvim_set_hl(0, "IlluminatedWordRead", { link = hicolor })
    vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { link = hicolor })
  end
})
