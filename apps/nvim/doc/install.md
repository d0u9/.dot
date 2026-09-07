# Installing this neovim configuration

Run the repo's installer from the root of `.dot`:

```
./install.sh -i nvim
```

It symlinks `apps/nvim` to `$HOME/.config/nvim` and then bootstraps
everything below. Re-running it is safe.

## What happens automatically

Nothing in this list needs a manual step; it is here so you know what the
installer is doing and where each piece keeps its state.

| Step | Driven by | Lands in |
| --- | --- | --- |
| lazy.nvim clones itself | `init.lua`, on the first start | `runtime/plugins/lazy/lazy.nvim` |
| Plugins are installed | `plugins/install.lua` via `:Lazy sync` | `runtime/plugins/lazy/` |
| Plugin versions are pinned | `:Lazy sync` writing the lockfile | `lazy-lock.json` (tracked in git) |
| LSP servers are installed | `plugins/configs/lsp-servers.lua` | `runtime/mason/` |
| Parsers are installed | `plugins/configs/treesitter-languages.lua` | `runtime/treesitter/` |

Everything generated lives under `runtime/`, which is gitignored. Deleting
that directory and starting nvim rebuilds all of it.

Two of these behave differently outside the installer, which is why the
installer does them explicitly:

- `mason-lspconfig`'s `ensure_installed` is **skipped in headless mode**, so
  the installer translates the server list into mason package names and calls
  `:MasonInstall` itself. In an interactive nvim, `ensure_installed` covers
  it.
- The tree-sitter parser install is asynchronous. The installer waits for the
  first run so a fresh host is actually finished when the script returns.

## What has to be on the host first

### Always

| Needed for | macOS | Debian/Ubuntu |
| --- | --- | --- |
| neovim 0.12+ | `brew install neovim` | distro packages lag; see the neovim wiki |
| cloning plugins | `git` | `git` |
| downloading parsers and servers | `curl`, `tar` (preinstalled) | `curl tar` |
| building parsers | Xcode command line tools | `build-essential` |
| building parsers | `brew install tree-sitter-cli` | `cargo install tree-sitter-cli` |
| fzf-lua's live grep | `brew install ripgrep` | `apt install ripgrep` |

The tree-sitter one is the easy mistake: the formula called **`tree-sitter`
is the library only** and leaves no binary in `$PATH`. The CLI is
`tree-sitter-cli`. The installer checks for it and refuses to continue
without it, because nvim-treesitter's `main` branch cannot build a parser
otherwise.

### Per language

A server is only requested on a host that has a working toolchain for the
language it serves, so a machine without Go is not asked to install gopls.
The checks live in `plugins/configs/lsp-servers.lua`:

| Server | Language | Installed when | Mason needs |
| --- | --- | --- | --- |
| `rust_analyzer` | Rust | `cargo` is in `$PATH` | nothing (prebuilt release) |
| `gopls` | Go | `go env GOROOT` succeeds | a Go toolchain — it runs `go install` |
| `lua_ls` | Lua | always | nothing (prebuilt release) |

Without this gate mason retries the missing server on every start and
reports the failure each time. Install the toolchain and restart, and the
server is picked up on its own; `:MasonInstall` still installs anything by
hand regardless of the gate.

Automatic enabling uses the same gated list, excluding `rust_analyzer`
because rustaceanvim starts that client. Other servers installed manually
through Mason are not automatically enabled; add them to the shared list or
configure and enable them explicitly with `vim.lsp.config` / `vim.lsp.enable`.

`lua_ls` has no condition: it ships as a prebuilt binary and this config is
itself lua, so it is always wanted.

## Adding to the setup

Each list has exactly one home, shared by the running config and the
installer. Add the entry, restart nvim, and commit the lockfile if it moved.

| To add | Edit | Then |
| --- | --- | --- |
| a plugin | `plugins/install.lua` | `:Lazy sync` |
| an LSP server | `plugins/configs/lsp-servers.lua` | restart, or `:MasonInstall` |
| a parser | `plugins/configs/treesitter-languages.lua` | restart, or `:TSInstall` |

Completion is provided by Blink's stable v1 release. Its configuration lives
in `plugins/configs/blink--cmp.lua`; the Lua fuzzy matcher is selected so a
normal startup never downloads or builds a host-specific matcher binary.

LSP servers are named the way nvim-lspconfig names them (`lua_ls`), not the
way mason does (`lua-language-server`); the installer translates between the
two. The mapping is in
[mason-lspconfig's server list](https://github.com/mason-org/mason-lspconfig.nvim/blob/main/doc/server-mapping.md).

A server that needs settings gets them in `plugins/configs/nvim-lspconfig.lua`,
next to the existing `vim.lsp.config` calls. Rust is the exception: it is not
started through lspconfig at all, but by rustaceanvim, and is configured in
`plugins/configs/rustaceanvim.lua`.

## Checking the result

Tree-sitter loads at startup as required by upstream, so its management
commands are available even without opening a file. Command-driven plugins
keep their entry points in the lazy spec's `cmd` list; update that list when
an upgrade introduces new commands.

```
:Lazy          plugin status
:Mason         LSP server status
:checkhealth   neovim's own diagnosis, including treesitter and lsp
```

See [the plugin maintenance review](plugin-review-2026-09.md) for the
2026-09-06 upstream status snapshot and migration candidates.
