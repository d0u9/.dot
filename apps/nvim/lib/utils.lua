-- `local`, because several plugin configs assign a global `M`, which would
-- otherwise clobber this one.
local M = {}

local ensure_directory_exists = function(dir_path)
  local command = string.format("mkdir -p %s", dir_path)
  os.execute(command)
end
M.ensure_directory_exists = ensure_directory_exists

local run_cb_if_has = function(cb, lib, ...)
  local status, _ = pcall(require, lib)
  if (not status) then return end

  for i = 1, select('#', ...) do
    local findit = pcall(require, select(i, ...))
    if (not findit) then return end
  end

  cb()
end
M.run_cb_if_has = run_cb_if_has

-- Defer `require_if_has` until a buffer of one of `filetypes` is opened, so a
-- language's plugins stay out of every other language's session. Pair it with
-- a matching `ft` in the lazy spec: without that the plugin loads at startup
-- anyway, and without this the require here is what loads it.
local require_on_ft = function(mod, filetypes, lib, ...)
  local args = { ... }
  vim.api.nvim_create_autocmd('FileType', {
    pattern = filetypes,
    once = true,
    callback = function()
      M.require_if_has(mod, lib, (unpack or table.unpack)(args))
    end,
  })
end
M.require_on_ft = require_on_ft

local require_if_has = function(mod, lib, ...)
  local cb = function()
    require(mod)
  end

  run_cb_if_has(cb, lib, ...)
end
M.require_if_has = require_if_has

return M
