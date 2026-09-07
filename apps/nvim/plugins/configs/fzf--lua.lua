require('fzf-lua').setup({
  -- Keep the familiar side-by-side layout while using fzf's matcher.
  'telescope',
  winopts = {
    preview = {
      wrap = true,
    },
  },
  files = {
    fd_opts = [[--color=never --type f --type l --exclude .git --exclude .jj --exclude '*.o']],
    rg_opts = [[--color=never --files -g '!.git' -g '!.jj' -g '!*.o']],
  },
  grep = {
    rg_opts = [[--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --max-depth 10 --glob '!*.o' -e]],
  },
  git = {
    files = {
      cmd = [[git ls-files --exclude-standard -- ':!:*.o']],
    },
  },
})
