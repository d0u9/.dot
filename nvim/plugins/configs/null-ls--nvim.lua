local null_ls = require("null-ls")

local sources = {
  null_ls.builtins.formatting.rustfmt,
  null_ls.builtins.formatting.gofmt,
  null_ls.builtins.code_actions.gitsigns,
  -- null_ls.builtins.formatting.stylua,
  -- null_ls.builtins.formatting.lua_format,
  -- null_ls.builtins.diagnostics.eslint_d,
  null_ls.builtins.formatting.prettier.with({
    filetypes = { "html", "json", "yaml", "markdown", "css" },
  }),
}

require('null-ls').setup({
  sources = sources,
})
