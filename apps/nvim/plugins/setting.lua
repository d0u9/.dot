local require_if_has = require('lib.utils').require_if_has

-- https://github.com/catppuccin/nvim
require_if_has('plugins.configs.catppuccin', 'catppuccin')

------------------------ LSP things ------------------------

-- https://github.com/mrcjkb/rustaceanvim
-- Only sets `vim.g.rustaceanvim`, which has to be in place before the plugin
-- loads, so this one is not deferred -- the plugin itself is, by its `ft`.
require('plugins.configs.rustaceanvim')

-- https://github.com/williamboman/mason.nvim
require_if_has('plugins.configs.mason--nvim', 'mason', 'lspconfig')

-- Configure shared LSP capabilities and server-specific settings before
-- mason-lspconfig automatically enables the wanted servers.
require_if_has('plugins.configs.nvim-lspconfig', 'lspconfig', 'cmp_nvim_lsp')

-- https://github.com/williamboman/mason-lspconfig.nvim
require_if_has('plugins.configs.mason-lspconfig--nvim', 'mason', 'mason-lspconfig', 'lspconfig')

-- null-ls is deprecated --
-- -- https://github.com/jose-elias-alvarez/null-ls.nvim
--require_if_has('plugins.configs.null-ls--nvim', 'null-ls', 'mason')

-- https://github.com/SmiteshP/nvim-navic
require_if_has('plugins.configs.nvim-navic', 'nvim-navic', 'lspconfig')


