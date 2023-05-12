----------- nvim-treesitter -----------
function config_nvim_treesitter()
  require('nvim-treesitter.configs').setup {
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
  }
end

