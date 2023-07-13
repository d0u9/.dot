M = {}

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

local require_if_has = function(mod, lib, ...)
  local cb = function()
    require(mod)
  end

  run_cb_if_has(cb, lib, ...)
end
M.require_if_has = require_if_has

return M
