----------- gitgutter -----------
function config_gitgutter()
  vim.api.nvim_command('autocmd BufWritePost * GitGutter')
end

