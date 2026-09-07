local opts = {
  kind = "split",
  integrations = {
    diffview = true,
    fzf_lua = true,
  },
}

require('neogit').setup(opts)
