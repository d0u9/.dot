# Plugin maintenance review — 2026-09-06

Scope: all 25 repositories in the active plugin spec after the Blink and fzf-lua migrations,
including dependencies
and the lazy.nvim bootstrap. Commented-out plugins are not active dependencies.
The lockfile was not updated and no plugins were installed or replaced.

## Method and limits

Checked GitHub's repository API (`https://api.github.com/repos/{owner}/{repo}`)
for canonical names, `archived`, and `pushed_at`, then reviewed upstream
documentation and maintenance discussions for the main concerns and alternatives.
All repositories returned `archived: false`. The dates below are repository
push dates, not necessarily default-branch commits or releases. A quiet repository
is not by itself evidence of abandonment; these checks are not a compatibility
test of the newest versions against this configuration.

## Main recommendations

1. **Plenary was removed.** Its
   [README notice](https://github.com/nvim-lua/plenary.nvim#important-notice)
   says ongoing support should not be expected, with critical fixes only
   potentially addressed until 2026-06-30. This matters even though GitHub still
   reports it as unarchived. fzf-lua now replaces Telescope, and the current
   Neogit release provides its own async implementation, so neither Plenary nor
   Telescope remains in the active spec or lockfile.
2. **Prioritize reviewing a Diffview migration.** The original repository's last
   push was in 2024. The fork maintainer describes unsuccessful attempts to reach
   the original author in [Neogit's migration issue](https://github.com/NeogitOrg/neogit/issues/1921).
   [diffview-plus.nvim](https://github.com/dlyongemallo/diffview-plus.nvim) is an
   actively maintained fork retaining the `diffview` module and main commands.
   It documents Neogit integration, but also has breaking changes. Migration
   should check the changelog, lazy dependency name, command list, lockfile,
   file history, and Neogit integration before replacing the original.
3. **Blink v1 now provides completion.**
   [Blink](https://github.com/saghen/blink.cmp) replaced nvim-cmp and its six
   source/formatting dependencies. The spec follows upstream's stable
   `version = '1.*'` recommendation because v2 on main has breaking changes.
   The migration preserves Tab/Enter behavior, command-line completion,
   signature help, native snippets and Rust/shared LSP capabilities. It uses
   the Lua fuzzy matcher to avoid downloading a host-specific binary at runtime.
4. **Keep Treesitter.** The repository is currently unarchived, and the
   [upstream discussion](https://github.com/nvim-treesitter/nvim-treesitter/discussions/8643)
   records its reopening. The old `master` branch is frozen; the
   [current main README](https://github.com/nvim-treesitter/nvim-treesitter/blob/main/README.md)
   documents the rewritten API already used here. A historical archive notice
   is not a reason to migrate this configuration now.
5. **Treat Snacks/Oil as workflow choices.**
   [Snacks](https://github.com/folke/snacks.nvim) offers picker, explorer,
   terminal and word-reference modules, potentially consolidating fzf-lua,
   nvim-tree, Toggleterm and Illuminate. This is a larger migration with different
   APIs and behavior, not an automatic improvement. fzf-lua and nvim-tree
   both have recent activity. [Oil](https://github.com/stevearc/oil.nvim) is worth
   considering specifically for editing directory entries like a text buffer;
   it is a different workflow from the current sidebar tree.
6. **Watch Toggleterm, but retain it if it works.** Its last repository push is
   March 2025. This is a low-activity signal, not proof of abandonment. Its
   [roadmap](https://github.com/akinsho/toggleterm.nvim#roadmap) explicitly limits
   feature scope. For this config's minimal setup, Snacks terminal is an
   alternative if Snacks is also adopted for other functions; installing a
   suite solely to replace a working
   terminal toggle has little demonstrated benefit.
7. **Keep nvim-lspconfig, but avoid its legacy module.** The
   [upstream README](https://github.com/neovim/nvim-lspconfig#important)
   distinguishes the deprecated `require('lspconfig')` framework from the
   maintained server configuration repository. Server setup here already uses
   `vim.lsp.config`; however, `plugins/setting.lua` still uses `require('lspconfig')`
   as a presence check. That guard should be modernized before upgrading to a
   version that removes the legacy module, otherwise `require_if_has` could
   silently skip dependent setup.

## Repository snapshot

Names below are the current canonical repositories. All are unarchived.

| Repository | Last repository push (UTC) |
| --- | --- |
| [folke/lazy.nvim](https://github.com/folke/lazy.nvim) | 2026-06-29 |
| [catppuccin/nvim](https://github.com/catppuccin/nvim) | 2026-08-09 |
| [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | 2026-09-04 |
| [mason-org/mason.nvim](https://github.com/mason-org/mason.nvim) | 2026-06-19 |
| [mason-org/mason-lspconfig.nvim](https://github.com/mason-org/mason-lspconfig.nvim) | 2026-08-27 |
| [SmiteshP/nvim-navic](https://github.com/SmiteshP/nvim-navic) | 2026-09-02 |
| [mrcjkb/rustaceanvim](https://github.com/mrcjkb/rustaceanvim) | 2026-09-06 |
| [ray-x/go.nvim](https://github.com/ray-x/go.nvim) | 2026-06-04 |
| [ray-x/guihua.lua](https://github.com/ray-x/guihua.lua) | 2026-07-03 |
| [saghen/blink.cmp](https://github.com/saghen/blink.cmp) | 2026-09-06 |
| [RRethy/vim-illuminate](https://github.com/RRethy/vim-illuminate) | 2026-08-25 |
| [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | 2026-05-31 |
| [hedyhli/outline.nvim](https://github.com/hedyhli/outline.nvim) | 2026-05-29 |
| [kevinhwang91/nvim-ufo](https://github.com/kevinhwang91/nvim-ufo) | 2026-01-11 |
| [kevinhwang91/promise-async](https://github.com/kevinhwang91/promise-async) | 2024-08-04 |
| [sindrets/diffview.nvim](https://github.com/sindrets/diffview.nvim) | 2024-08-02 |
| [akinsho/toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | 2025-03-09 |
| [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | 2026-09-05 |
| [nvim-tree/nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) | 2026-08-12 |
| [nvim-tree/nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) | 2026-08-30 |
| [ibhagwan/fzf-lua](https://github.com/ibhagwan/fzf-lua) | 2026-09-07 |
| [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | 2026-08-11 |
| [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive) | 2026-03-07 |
| [NeogitOrg/neogit](https://github.com/NeogitOrg/neogit) | 2026-08-22 |
| [lambdalisue/vim-suda](https://github.com/lambdalisue/vim-suda) | 2025-10-29 |

## Renamed or transferred repositories

These spec entries resolve successfully but use old repository names:

| Current spec | Canonical repository |
| --- | --- |
| `williamboman/mason.nvim` | `mason-org/mason.nvim` |
| `williamboman/mason-lspconfig.nvim` | `mason-org/mason-lspconfig.nvim` |
| `kyazdani42/nvim-tree.lua` | `nvim-tree/nvim-tree.lua` |
| `lambdalisue/suda.vim` | `lambdalisue/vim-suda` |

These are not abandoned plugins. A future naming cleanup should preserve the
existing lazy name (`suda.vim`) explicitly or migrate its lockfile entry and
installation directory together.

The commented null-ls spec and its unused configuration are legacy leftovers;
they are not loaded. Current Rust and outline specs already use rustaceanvim
and outline.nvim, rather than their predecessors.
