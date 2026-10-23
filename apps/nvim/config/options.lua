-- General editing behavior
vim.opt.confirm = true -- Ask whether to save unsaved buffers when quitting.
vim.opt.mouse = 'a'
vim.opt.shortmess:append('filmnrxoOtT')
vim.opt.viewoptions = { 'folds', 'options', 'cursor', 'unix', 'slash' }
vim.opt.virtualedit = { 'onemore' }
vim.opt.iskeyword:remove({ '.', '#', '-' })

vim.opt.backup = true
vim.opt.undofile = true
vim.opt.undolevels = 1000
vim.opt.undoreload = 10000

if vim.env.SSH_TTY or vim.env.SSH_CONNECTION or vim.env.ZELLIJ then
  local osc52 = require('vim.ui.clipboard.osc52')
  local copy, paste = {}, {}
  for _, register in ipairs({ '+', '*' }) do
    local cached = { {}, 'v' }
    local send = osc52.copy(register)
    copy[register] = function(lines, regtype)
      cached = { vim.deepcopy(lines), regtype }
      send(lines, regtype)
    end
    -- Terminal paste (Cmd+V) supplies local text; p uses this session's copy.
    -- Never query OSC 52 here: multiplexers may not support clipboard reads.
    paste[register] = function()
      return vim.deepcopy(cached)
    end
  end
  vim.g.clipboard = { name = 'OSC 52', copy = copy, paste = paste }
end
vim.opt.clipboard:append('unnamedplus')

-- UI
vim.opt.showmode = false -- lualine already shows the current mode
vim.opt.colorcolumn = '80'
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.number = true
vim.opt.showmatch = true
vim.opt.winminheight = 0
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wildmode = { 'longest', 'full' }
vim.opt.whichwrap = 'b,s,h,l,<,>,[,]'
vim.opt.scrolljump = 5
vim.opt.scrolloff = 3
vim.opt.foldenable = true
vim.opt.list = true
vim.opt.signcolumn = 'yes'
vim.opt.listchars = {
  tab = '› ',
  trail = '•',
  extends = '+',
  nbsp = '.',
}

-- Default indentation; language-specific overrides live in after/ftplugin/.
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.splitkeep = 'screen'
vim.opt.winborder = 'rounded'

-- Traditional C syntax treats headers as C rather than C++.
vim.g.c_syntax_for_h = 1
