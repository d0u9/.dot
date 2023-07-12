local vimscripts_dir = _G.CONFIG_DIR .. 'vimscripts'

vim.cmd('source' .. vimscripts_dir .. '/basic.vim')

-- nvim's file forma
vim.cmd('source' .. vimscripts_dir .. '/file_formatting.vim')

-- colors
vim.cmd('source' .. vimscripts_dir .. '/color.vim')
