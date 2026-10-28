# Installing this neovim configuration

Run the repo's installer from the root of `.dot`:

```
./install.sh nvim
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
| Plugin versions are recorded | `:Lazy sync` writing the lockfile | `runtime/lazy-lock.json` (per host, ignored) |
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
`tree-sitter-cli`. Parsers are the `treesitter` item, on by default
(`install.sh nvim:` leaves it out). It is kept only when `cc` exists and
`tree-sitter --version` runs: the official Linux binary needs a recent glibc,
and on an older one such as EL9's 2.34 `cargo install tree-sitter-cli` is the
way. Otherwise the installer warns and deletes `runtime/treesitter.on`, the
marker `plugins/install.lua` reads; without it nvim-treesitter is disabled,
`Lazy! sync` removes it, and highlighting falls back to regex.

### Per language

A server is only requested on a host that has a working toolchain for the
language it serves, so a machine without Go is not asked to install gopls.
The checks live in `plugins/configs/lsp-servers.lua`:

| Server | Language | Installed when | Mason needs |
| --- | --- | --- | --- |
| `rust_analyzer` | Rust | `cargo` is in `$PATH` | nothing (prebuilt release) |
| `gopls` | Go | `go env GOROOT` succeeds | a Go toolchain — it runs `go install` |
| `lua_ls` | Lua | always | nothing (prebuilt release) |
| `clangd` | C, C++ | `cc` is in `$PATH` | nothing (prebuilt release) |

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

## Clipboard over SSH and Zellij

Use this Neovim configuration on the remote host and the Alacritty
configuration on the local machine. In SSH or Zellij sessions, Neovim uses
its built-in OSC 52 provider for copies, so `yy` and visual-mode `y` update
the local system clipboard without a remote clipboard utility.

Zellij uses OSC 52 by default; leave `copy_command` unset so it does not
redirect copies to a utility on the remote host. This works with Zellij
on either side of the SSH connection.

In Alacritty, `Cmd+V` sends the local clipboard to the focused pane. In
Neovim, use Insert mode for a predictable insertion point. OSC 52 clipboard
reads are not needed: Alacritty allows copies only, and Neovim's `p` uses
the last value copied to that register in the current editor session,
not clipboard changes made by other local applications. Outside SSH and
Zellij, Neovim keeps its normal system clipboard provider.

After syncing these files, restart Neovim on the remote host. No new
plugins or executables are needed.

## Closing previews

`Esc` closes LSP previews from the source window or the preview itself.
It also closes Lazy, UFO and Go previews, and hides an fzf picker when pressed
in its preview. In Insert mode, it hides Blink completion and signature popups
and returns to Normal mode. The generic floating-window fallback leaves
buffers with unsaved changes open.

## Adding to the setup

C buffers use the global indentation defaults (four spaces) unless the
project's `.editorconfig` overrides them. Kernel-style tabs belong in the
project configuration rather than the C ftplugin.

Each list has exactly one home, shared by the running config and the
installer. Add the entry, and restart nvim.

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

clangd reads each project's compiler flags from its `compile_commands.json`,
found by walking up from the open file; a project without one gets no useful
completion. Per-project flag fixes belong in that project's `.clangd`, not in
this configuration. `--query-driver` allows the gcc-style compilers in the
absolute `$PATH` directories (`*gcc*`, `*g++*`, `cc`, `c++`), so clangd can ask
them for their builtin include paths; a compiler elsewhere is not run and its
system headers may be reported missing.

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
