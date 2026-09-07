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

-- `auto_attach` is off because navic would then attach to every client,
-- including ones whose symbols are useless in a breadcrumb. Attach it here
-- instead, once per client that can answer documentSymbol, so that every
-- server gets a winbar -- previously only gopls and rust-analyzer did, because
-- they were the only two configured with an explicit `on_attach`.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('dot_navic_attach', { clear = true }),
  desc = 'Attach nvim-navic to symbol-capable LSP clients',
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method('textDocument/documentSymbol') then
      require('nvim-navic').attach(client, args.buf)
    end
  end,
})
