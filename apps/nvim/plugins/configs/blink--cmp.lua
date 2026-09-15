require('blink.cmp').setup({
  keymap = {
    preset = 'none',
    ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
    -- Was <C-Space>, which macOS eats for the input-source switcher before it
    -- ever reaches the terminal. <C-n> shadows the native keyword completion
    -- (i_CTRL-N), which blink replaces anyway. Pressing it again toggles the
    -- documentation window, which `completion.documentation` keeps off by
    -- default.
    ['<C-n>'] = { 'show', 'show_documentation', 'hide_documentation' },
    ['<C-e>'] = { 'cancel', 'fallback' },
    -- Match nvim-cmp's previous `confirm({ select = true })` behavior.
    ['<CR>'] = { 'select_and_accept', 'fallback' },
    ['<Tab>'] = { 'select_next', 'fallback' },
    ['<S-Tab>'] = { 'select_prev', 'fallback' },
  },
  completion = {
    documentation = { auto_show = false },
    menu = {
      draw = {
        columns = {
          { 'kind_icon' },
          { 'label', 'label_description', gap = 1 },
          { 'source_name' },
        },
        components = {
          label = { width = { max = 45 } },
          source_name = {
            text = function(ctx)
              local labels = {
                buffer = '[BUF]',
                lsp = '[LSP]',
                path = '[PATH]',
                snippets = '[SNP]',
              }
              return labels[ctx.source_id] or ('[' .. ctx.source_name .. ']')
            end,
          },
        },
      },
    },
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
    providers = {
      buffer = { min_keyword_length = 3 },
    },
  },
  signature = { enabled = true },
  -- Avoid a runtime download and keep the configuration portable. Neovim
  -- 0.12 is fast enough for Blink's Lua matcher at this setup's scale.
  fuzzy = { implementation = 'lua' },
})
