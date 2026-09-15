local gitcommit = vim.api.nvim_create_augroup('dot_gitcommit', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = gitcommit,
  pattern = 'gitcommit',
  desc = 'Configure Git commit messages',
  callback = function(args)
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    vim.bo[args.buf].textwidth = 72
    vim.wo.spell = true
  end,
})
