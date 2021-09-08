local function setup_if_has(cb, lib, ...)
  local status, l = pcall(require, lib)
  if (not status) then return end
  for i = 1, select('#', ...) do
    local findit = pcall(require, select(i, ...))
    if (not findit) then return end
  end

  cb()
end

---------- nvim-lsconfig -----------
local function config_nvim_lsconfig()
  require('lspconfig').gopls.setup{}
  require('lspconfig').rust_analyzer.setup{}
end
setup_if_has(config_nvim_lsconfig, 'lspconfig')

----------- nvim-cmp -----------
function config_nvim_cmp()
  local cmp = require('cmp')
  cmp.setup {
    preselect = cmp.PreselectMode.None,
    snippet = {
      expand = function(args)
        vim.fn['vsnip#anonymous'](args.body)
      end
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
        else
          fallback()
        end
      end,
      ['<S-Tab>'] = function(fallback)
        if vim.fn.pumvisible() == 1 then
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-p>', true, true, true), 'n')
        else
          fallback()
        end
      end,
    },
    sources = {
      { name = 'nvim_lsp' },
    },
  }
end
setup_if_has(config_nvim_cmp, 'cmp')

----------- nvim-treesitter -----------
function config_nvim_treesitter()
  require('nvim-treesitter.configs').setup {
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
  }
end
setup_if_has(config_nvim_treesitter, 'nvim-treesitter')

----------- telescope -----------
function config_telescope()
  require('telescope').setup{
    defaults = {
      vimgrep_arguments = {
        'ag',
        '--vimgrep',
        '--depth',
        '5',
        '--ignore',
        'exe|so|dll|class|png|jpg|jpeg|doc|docx|pdf|icon|gif|out|o',
      },
    },
    file_ignore_patterns = {"%.o"},
  }
end
setup_if_has(config_telescope, 'telescope')

----------- kommentary -----------
function config_kommentary()
  vim.g.kommentary_create_default_mappings = false
  require('kommentary.config').configure_language("default", {
    prefer_single_line_comments = true,
  })
end
setup_if_has(config_kommentary, 'kommentary')
