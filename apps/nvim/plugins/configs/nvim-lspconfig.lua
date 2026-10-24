local capabilities = require('blink.cmp').get_lsp_capabilities()

-- Apply completion capabilities to every server enabled by mason-lspconfig.
vim.lsp.config('*', {
  capabilities = capabilities,
})

local wanted = {}
for _, server in ipairs(require('plugins.configs.lsp-servers')) do
  wanted[server] = true
end

-- clangd runs the compiler named in compile_commands.json to learn its builtin
-- include paths, but only when it matches `--query-driver`. Allow gcc-style
-- compilers (system, Homebrew, cross) from the absolute directories on $PATH;
-- a match anywhere (`**/*gcc*`) would let an untrusted checkout run its own
-- binaries. clang drivers need no query.
local function clangd_query_drivers()
  local globs, seen = {}, {}
  for dir in vim.gsplit(vim.env.PATH or '', ':', { plain = true }) do
    dir = dir:gsub('/+$', '')
    if dir:sub(1, 1) == '/' and not seen[dir] then
      seen[dir] = true
      for _, name in ipairs({ '*gcc*', '*g++*', 'cc', 'c++' }) do
        table.insert(globs, dir .. '/' .. name)
      end
    end
  end
  return table.concat(globs, ',')
end

if wanted.clangd then
  vim.lsp.config('clangd', {
    cmd = {
      'clangd',
      '--background-index',
      -- Auto-inserted includes are often wrong in QEMU and the kernel.
      '--header-insertion=never',
      '--query-driver=' .. clangd_query_drivers(),
    },
  })
end

-- Do not register or enable gopls on hosts without a Go toolchain. The same
-- wanted-server list also drives Mason installation and automatic enabling.
if wanted.gopls then
  vim.lsp.config('gopls', {
    cmd = { 'gopls', 'serve' },
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
      },
    },
  })
end
