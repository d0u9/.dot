-- nvim-treesitter's `main` branch dropped `nvim-treesitter.configs`: parsers
-- are installed through the module's own `install()`, and highlighting is
-- started per buffer with `vim.treesitter.start()`.
--
-- Installing parsers needs the tree-sitter CLI (the `tree-sitter-cli` brew
-- formula, not `tree-sitter`, which ships only the library) plus a C compiler.
local ts = require('nvim-treesitter')

ts.setup({
  -- Keep the parsers with everything else this config generates.
  install_dir = _G.RUNTIME_DIR .. '/treesitter',
})

local languages = require('plugins.configs.treesitter-languages')

-- A no-op once the parsers are there; the install script does the first,
-- blocking, run.
ts.install(languages)

-- `main` no longer turns highlighting on by itself.
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('nvim_treesitter_highlight', { clear = true }),
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if lang and vim.treesitter.language.add(lang) then
      vim.treesitter.start(args.buf, lang)
    end
  end,
})
