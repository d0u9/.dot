vim.opt.background = 'dark'

local ok, err = pcall(vim.cmd.colorscheme, _G.THEME())
if not ok then
  vim.notify('Failed to load colorscheme: ' .. err, vim.log.levels.WARN)
end
