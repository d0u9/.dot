----------- telescope -----------
function config_telescope()
  require('telescope').setup{
    defaults = {
      vimgrep_arguments = {
        'rg',
        '--vimgrep',
        '--max-depth',
        '5',
      },
    },
    file_ignore_patterns = {"%.o"},
  }
end

