vim.opt_local.cindent = true
vim.opt_local.cinoptions = 'g-1,:0,(0,w0'
-- Neovim's C++ ftplugin also sources this file; hide whitespace only for C.
if vim.bo.filetype == 'c' then
  vim.opt_local.list = false
end
