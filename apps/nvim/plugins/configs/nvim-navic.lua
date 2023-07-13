local icons = {
  file          = "󰈙 ",
  module        = " ",
  namespace     = "󰌗 ",
  package       = " ",
  class         = "󰌗 ",
  Method        = "󰆧 ",
  Property      = " ",
  Field         = " ",
  Constructor   = " ",
  Enum          = "󱡠 ",
  Interface     = "󰕘 ",
  Function      = "󰊕 ",
  Variable      = "󰆧 ",
  Constant      = "󰏿 ",
  String        = "󰀬 ",
  Number        = "󰎠 ",
  Boolean       = "◩ ",
  Array         = "󰅪 ",
  Object        = "󰅩 ",
  Key           = "󰌋 ",
  Null          = "󰟢 ",
  EnumMember    = " ",
  Struct        = "󰌗 ",
  Event         = " ",
  Operator      = "󰆕 ",
  TypeParameter = "󰊄 ",
}

local lsp = {
  auto_attach = false,
  preference = nil,
}

local opts = {
  icons = icons,
  lsp = lsp,
  highlight = true,
  separator = " > ",
  depth_limit = 0,
  depth_limit_indicator = "..",
  safe_output = true,
  click = false,
}

require("nvim-navic").setup(opts)
