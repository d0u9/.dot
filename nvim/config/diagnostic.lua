vim.diagnostic.config({
  virtual_text = {
    severity = vim.diagnostic.severity.ERROR,
  },
  severity_sort = true,
  float = {
    source = "always",  -- Or "if_many"
  },
})

