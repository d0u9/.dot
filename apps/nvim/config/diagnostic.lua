vim.diagnostic.config({
  virtual_text = {
    severity = vim.diagnostic.severity.ERROR,
  },
  severity_sort = true,
  float = {
    -- `source` is boolean|"if_many"; the old "always" only worked by being
    -- truthy.
    source = true,
  },
  jump = {
    -- `goto_next`/`goto_prev` used to open the float on arrival. `jump()`
    -- does not, so put it back here rather than through the deprecated
    -- `jump.float`.
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({ bufnr = bufnr, scope = 'cursor', focus = false })
    end,
  },
})

-- Neovim maps `gf` inside the diagnostic float to follow a diagnostic's
-- "related information" link. Only the indented `file:line:col:` lines carry
-- one; on the `Diagnostics:` header or the message itself the mapping falls
-- back to a plain `gf`, which tries to open a file named after the word under
-- the cursor and throws E447 with a stack trace. Wrap the mapping so a miss is
-- a one-line message instead. The real jump is untouched -- the location table
-- it needs is a local inside Neovim's function, so the original callback is
-- kept and only its failure is caught.
local open_float = vim.diagnostic.open_float

vim.diagnostic.open_float = function(...)
  local float_bufnr, winid = open_float(...)
  if not float_bufnr then
    return float_bufnr, winid
  end

  for _, map in ipairs(vim.api.nvim_buf_get_keymap(float_bufnr, 'n')) do
    if map.lhs == 'gf' and map.callback then
      local follow = map.callback
      vim.keymap.set('n', 'gf', function()
        if not pcall(follow) then
          vim.api.nvim_echo({ { 'No related location on this line', 'WarningMsg' } }, false, {})
        end
      end, { buffer = float_bufnr, remap = false })
      break
    end
  end

  return float_bufnr, winid
end
