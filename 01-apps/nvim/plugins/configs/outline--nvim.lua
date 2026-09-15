-- outline.nvim is the maintained successor of symbols-outline.nvim, which the
-- author archived. The options below are the old symbols-outline settings
-- rearranged into the groups this plugin expects.
local opts = {
  guides = {
    enabled = true,
  },
  outline_items = {
    show_symbol_details = true,
    highlight_hovered_item = true,
  },
  outline_window = {
    position = 'right',
    relative_width = true,
    width = 20,
    auto_close = false,
    wrap = false,
    show_numbers = false,
    show_relative_numbers = false,
  },
  preview_window = {
    auto_preview = false,
    winhl = 'NormalFloat:Pmenu',
  },
  symbol_folding = {
    -- nil keeps every symbol unfolded on open, as before.
    autofold_depth = nil,
    auto_unfold = { hovered = true },
    markers = { '', '' },
  },
  keymaps = {
    close = { '<Esc>', 'q' },
    goto_location = '<Cr>',
    goto_and_close = '<S-Cr>',
    hover_symbol = 'p',
    toggle_preview = 'K',
    rename_symbol = 'r',
    code_actions = 'a',
    fold = 'x',
    unfold = 'o',
    fold_all = 'W',
    unfold_all = 'E',
    fold_reset = 'R',
    -- 'o' is taken by unfold above, which is the binding muscle memory has.
    peek_location = 'P',
  },
  providers = {
    lsp = {
      blacklist_clients = {},
    },
  },
  symbols = {
    icons = {
      File = { icon = "", hl = "@text.uri" },
      Module = { icon = "", hl = "@namespace" },
      Namespace = { icon = "", hl = "@namespace" },
      Package = { icon = "", hl = "@namespace" },
      Class = { icon = "𝓒", hl = "@type" },
      Method = { icon = "ƒ", hl = "@method" },
      Property = { icon = "", hl = "@method" },
      Field = { icon = "", hl = "@field" },
      Constructor = { icon = "", hl = "@constructor" },
      Enum = { icon = "ℰ", hl = "@type" },
      Interface = { icon = "ﰮ", hl = "@type" },
      Function = { icon = "", hl = "@function" },
      Variable = { icon = "", hl = "@constant" },
      Constant = { icon = "", hl = "@constant" },
      String = { icon = "𝓐", hl = "@string" },
      Number = { icon = "#", hl = "@number" },
      Boolean = { icon = "⊨", hl = "@boolean" },
      Array = { icon = "", hl = "@constant" },
      Object = { icon = "⦿", hl = "@type" },
      Key = { icon = "🔐", hl = "@type" },
      Null = { icon = "NULL", hl = "@type" },
      EnumMember = { icon = "", hl = "@field" },
      Struct = { icon = "𝓢", hl = "@type" },
      Event = { icon = "🗲", hl = "@type" },
      Operator = { icon = "+", hl = "@operator" },
      TypeParameter = { icon = "𝙏", hl = "@parameter" },
      Component = { icon = "", hl = "@function" },
      Fragment = { icon = "", hl = "@constant" },
    },
  },
}

require("outline").setup(opts)
