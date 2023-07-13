require('telescope').setup{
  defaults = {
    wrap_results = true,
    vimgrep_arguments = {
      'rg',
      '--vimgrep',
      '--max-depth',
      '10',
    },
  },
  file_ignore_patterns = {"%.o"},
}
