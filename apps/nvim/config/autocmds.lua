local popup_keys = vim.api.nvim_create_augroup('dot_popup_keys', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = popup_keys,
  pattern = 'lazy',
  desc = 'Close Lazy with its own cleanup on Escape',
  callback = function(args)
    vim.keymap.set('n', '<Esc>', 'q', { buffer = args.buf, remap = true, nowait = true })
  end,
})

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
