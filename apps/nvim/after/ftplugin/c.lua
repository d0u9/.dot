vim.opt_local.cindent = true
vim.opt_local.cinoptions = 'g-1,:0,(0,w0'
vim.opt_local.tabstop = 8
vim.opt_local.shiftwidth = 8
vim.opt_local.softtabstop = 8
vim.opt_local.expandtab = false
-- Neovim's C++ ftplugin also sources this file; hide whitespace only for C.
if vim.bo.filetype == 'c' then
  vim.opt_local.list = false
end
