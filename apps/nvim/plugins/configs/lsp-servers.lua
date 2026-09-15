-- The LSP servers to install, named as nvim-lspconfig names them (which is
-- what mason-lspconfig's ensure_installed expects). Shared with the bootstrap
-- in apps/nvim-install.sh, which maps them to mason package names.
--
-- https://github.com/mason-org/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
--
-- A server is only asked for on a host that has the language it serves.
-- Without this, mason retries the install on every start and reports the
-- failure each time -- gopls in particular is built with `go install`, so it
-- cannot even be fetched without a Go toolchain.
local function go_toolchain_works()
  if vim.fn.executable('go') ~= 1 then return false end

  local result = vim.system({ 'go', 'env', 'GOROOT' }, { text = true }):wait()
  return result.code == 0 and result.stdout:match('%S') ~= nil
end

local servers = {
  { name = 'rust_analyzer', available = function() return vim.fn.executable('cargo') == 1 end },
  { name = 'gopls', available = go_toolchain_works },
  -- Lua needs no toolchain: the server ships as a prebuilt binary, and this
  -- config is itself lua, so it is always wanted.
  { name = 'lua_ls' },
}

local wanted = {}
for _, server in ipairs(servers) do
  if not server.available or server.available() then
    table.insert(wanted, server.name)
  end
end

return wanted
