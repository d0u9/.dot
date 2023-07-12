require('Comment').setup({
  toggler = {
    ---Line-comment toggle keymap
    line = 'cc',
    ---Block-comment toggle keymap
    block = 'cb',
  },
  ---LHS of operator-pending mappings in NORMAL and VISUAL mode
  opleader = {
    ---Line-comment keymap
    line = 'cc',
    ---Block-comment keymap
    block = 'cb',
  },
  mappings = {
    ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
    basic = true,
    ---Extra mapping; `gco`, `gcO`, `gcA`
    extra = false,
  },
})
