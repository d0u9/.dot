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

----------- lspkind-nvim -----------
function config_lspkind_nvim()
  require('lspkind').init({
    -- enables text annotations
    --
    -- default: true
    with_text = true,

    -- default symbol map
    -- can be either 'default' (requires nerd-fonts font) or
    -- 'codicons' for codicon preset (requires vscode-codicons font)
    --
    -- default: 'default'
    preset = 'codicons',

    -- override preset symbols
    --
    -- default: {}
    symbol_map = {
      Text = "",
      Method = "",
      Function = "",
      Constructor = "",
      Field = "ﰠ",
      Variable = "",
      Class = "ﴯ",
      Interface = "",
      Module = "",
      Property = "ﰠ",
      Unit = "塞",
      Value = "",
      Enum = "",
      Keyword = "",
      Snippet = "",
      Color = "",
      File = "",
      Reference = "",
      Folder = "",
      EnumMember = "",
      Constant = "",
      Struct = "פּ",
      Event = "",
      Operator = "",
      TypeParameter = ""
    },
  })
end
setup_if_has(config_lspkind_nvim, 'lspkind')

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
    sorting = {
      comparators = {
        cmp.config.compare.offset,
        cmp.config.compare.exact,
        cmp.config.compare.score,
        -- cmp.config.compare.kind,
        cmp.config.compare.sort_text,
        cmp.config.compare.length,
        -- cmp.config.compare.order,
      },
    },
    mapping = {
      -- ['<C-p>'] = cmp.mapping.select_prev_item(),
      -- ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-u>'] = cmp.mapping.scroll_docs(-4),
      ['<C-d>'] = cmp.mapping.scroll_docs(4),
      -- ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.close(),
      ['<CR>'] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Insert,
        -- select = true,
      },
      ['<Tab>'] = function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end,
      ['<S-Tab>'] = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end,
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'buffer' },
    },
    formatting = {
      format = function(entry, vim_item)
        -- fancy icons and a name of kind
        vim_item.kind = "      " .. require('lspkind').presets.default[vim_item.kind] .. " " .. vim_item.kind

        -- set a name for each source
        vim_item.menu = ({
          buffer = "[Buffer]",
          nvim_lsp = "[LSP]",
          luasnip = "[LuaSnip]",
          nvim_lua = "[Lua]",
          latex_symbols = "[Latex]",
        })[entry.source.name]
        return vim_item
      end,
    },
  }
end
setup_if_has(config_nvim_cmp, 'cmp', 'lspkind')

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
