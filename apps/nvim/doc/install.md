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
| telescope's live grep | `brew install ripgrep` | `apt install ripgrep` |

The tree-sitter one is the easy mistake: the formula called **`tree-sitter`
is the library only** and leaves no binary in `$PATH`. The CLI is
`tree-sitter-cli`. The installer checks for it and refuses to continue
without it, because nvim-treesitter's `main` branch cannot build a parser
otherwise.

### Per language

Mason downloads a prebuilt binary where one exists, and builds from source
where it does not. Only the second kind needs a toolchain present:

| Server | Language | Needs |
| --- | --- | --- |
| `rust_analyzer` | Rust | nothing (prebuilt release) |
| `lua_ls` | Lua | nothing (prebuilt release) |
| `gopls` | Go | a Go toolchain — mason runs `go install` |

A server whose toolchain is missing fails on its own without stopping the
rest of the install; the installer warns and moves on. Install the toolchain
and re-run, or use `:Mason` in nvim.

## Adding to the setup

Each list has exactly one home, shared by the running config and the
installer. Add the entry, restart nvim, and commit the lockfile if it moved.

| To add | Edit | Then |
| --- | --- | --- |
| a plugin | `plugins/install.lua` | `:Lazy sync` |
| an LSP server | `plugins/configs/lsp-servers.lua` | restart, or `:MasonInstall` |
| a parser | `plugins/configs/treesitter-languages.lua` | restart, or `:TSInstall` |

LSP servers are named the way nvim-lspconfig names them (`lua_ls`), not the
way mason does (`lua-language-server`); the installer translates between the
two. The mapping is in
[mason-lspconfig's server list](https://github.com/mason-org/mason-lspconfig.nvim/blob/main/doc/server-mapping.md).

A server that needs settings gets them in `plugins/configs/nvim-cmp.lua`,
next to the existing `vim.lsp.config` calls. Rust is the exception: it is not
started through lspconfig at all, but by rustaceanvim, and is configured in
`plugins/configs/rustaceanvim.lua`.

## Checking the result

```
:Lazy          plugin status
:Mason         LSP server status
:checkhealth   neovim's own diagnosis, including treesitter and lsp
```
