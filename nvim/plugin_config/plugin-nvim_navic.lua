----------- nvim-navic -----------
function config_nvim_navic()
  local navic = require("nvim-navic")

  -- For Rust
  -- NOTE: You cannot use the code below directly, because rust-tool hajacks all configurations.
  -- So, you have to add `on_attach` callbacks for rust-tool.
  --
  -- require("lspconfig").rust_analyzer.setup {
  --   on_attach = function(client, bufnr)
  --     navic.attach(client, bufnr)
  --   end
  -- }

  -- For Ruby
  require("lspconfig").solargraph.setup {
    on_attach = function(client, bufnr)
      navic.attach(client, bufnr)
    end
  }

  navic.setup {
    icons = {
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
    },
    lsp = {
        auto_attach = false,
        preference = nil,
    },
    highlight = false,
    separator = " > ",
    depth_limit = 0,
    depth_limit_indicator = "..",
    safe_output = true,
    click = false,
  }
end

