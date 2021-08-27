-- theme {
    vim.cmd('colorscheme nord')
-- }
--
-- nvim-lsconfig {
    require('lspconfig').gopls.setup{}
    require('lspconfig').rust_analyzer.setup{}
-- }

-- nvim-cmp {
    -- luasnip setup
    local luasnip = require 'luasnip'

    -- nvim-cmp setup
    local cmp = require 'cmp'
    cmp.setup {
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      },
      mapping = {
        -- ['<C-p>'] = cmp.mapping.select_prev_item(),
        -- ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        -- ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        },
        ['<Tab>'] = function(fallback)
          if vim.fn.pumvisible() == 1 then
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-n>', true, true, true), 'n')
          elseif luasnip.expand_or_jumpable() then
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), '')
          else
            fallback()
          end
        end,
        ['<S-Tab>'] = function(fallback)
          if vim.fn.pumvisible() == 1 then
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-p>', true, true, true), 'n')
          elseif luasnip.jumpable(-1) then
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-jump-prev', true, true, true), '')
          else
            fallback()
          end
        end,
      },
      sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
      },
    }
-- }

-- nvim-treesitter {
    require'nvim-treesitter.configs'.setup {
        highlight = {
            enable = true,
        },
    }
-- }

-- telescope {
   local builtin = require('telescope.builtin')
    require('telescope').setup{
        defaults = {
            vimgrep_arguments = {
                'ag',
                '--vimgrep',
            },
        },
    }
-- }

-- gitsigns {
  require('gitsigns').setup()
-- }

-- kommentary {
  vim.g.kommentary_create_default_mappings = false
  require('kommentary.config').configure_language("default", {
      prefer_single_line_comments = true,
  })
-- }
