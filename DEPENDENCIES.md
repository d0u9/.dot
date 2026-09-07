# Host dependencies

This is the starting point for provisioning a new macOS or Linux host. It
lists software that must already exist on the host, software that materially
improves the configured experience, and feature-specific tools that can be
left out.

Repository-managed plugins, parsers, language servers and generated caches
are listed separately at the end. Do not install those by hand on a new host.

## Required foundations

These are required by the repository itself or by its installers:

| Tool | Why it is required |
| --- | --- |
| Bash | Runs `install.sh` and every `apps/*-install.sh` installer. |
| Git | Clones Zsh, Neovim and tmux plugin repositories. |
| curl | Downloads Alacritty themes and resources used by editor tooling. |
| tar | Extracts downloaded tools and archives. |

Install the application whose configuration you plan to use. Zsh, Neovim,
Alacritty, Zellij and tmux are independent targets; installing one does not
require installing all of the others.

## Core Zsh and Neovim workstation

For the main shell and editor setup, install all of the following:

| Tool | Level | What it enables |
| --- | --- | --- |
| Zsh | Required for Zsh | The shell configuration, prompt and plugins. |
| Neovim 0.12+ | Required for Neovim | The editor configuration. |
| tree-sitter CLI | Required for Neovim | Builds the configured Tree-sitter parsers. The executable must be named `tree-sitter`. |
| C build toolchain | Required for Neovim | Compiles Tree-sitter parsers. Use Xcode Command Line Tools on macOS, `build-essential` on Debian/Ubuntu, or the distribution equivalent. |
| ripgrep (`rg`) | Strongly recommended | Powers fzf-lua live grep and fast project-wide searches. |
| fd | Strongly recommended | Gives fzf-lua a fast, convenient filesystem search backend. |
| eza | Strongly recommended | Replaces `ls` with colour and directory-first sorting. |
| fzf | Strongly recommended | Adds shell history/file fuzzy search and ZLE key bindings. |
| zoxide | Strongly recommended | Provides ranked directory navigation through `z` and `zi`. |
| Maple Mono NF CN | Strongly recommended | Matches the configured Alacritty font and supplies Nerd Font glyphs used by Neovim and tmux. |

On macOS, Homebrew is the preferred package source. In particular, install
`tree-sitter-cli`, not the similarly named `tree-sitter` library formula.
The Zsh installer tries to install `fzf` and `zoxide` through Homebrew, apt,
dnf, pacman or apk when they are missing. The other recommended tools remain
the host provisioner's responsibility.

## macOS GNU command layer

These packages are optional. The shell safely falls back to the macOS system
commands, but installing them makes command behaviour more consistent with
Linux. Candidate selection is defined in `apps/zsh/core/aliases.zsh`.

| Package | Commands used by the configuration |
| --- | --- |
| coreutils | `gls`, `gdircolors` |
| gnu-sed | `gsed` |
| grep | `ggrep` |
| findutils | `gfind`, `gxargs` |
| gnu-tar | `gtar` |

`eza` remains the first choice for `ls`; GNU `gls` is its macOS fallback.

## Language toolchains

Install these only on hosts that develop the corresponding language:

| Toolchain | Effect |
| --- | --- |
| Rust (`rustup`, `cargo`, `rustc`, `clippy`) | Makes the configuration request `rust_analyzer` and enables the Rust-specific editor workflow. |
| Go | Makes the configuration request `gopls` and enables the Go-specific editor workflow. |
| Python | Supports Python development and the virtual-environment prompt segment. |
| Ruby | Supports Ruby development; the parser and editor settings themselves do not require a local Ruby runtime. |
| Node.js/npm | Needed for JavaScript/TypeScript development, but not for the base editor bootstrap. |

Mason installs the configured language servers after the relevant toolchain
gate passes. `lua_ls` is always requested because it is distributed as a
prebuilt binary and the configuration itself is Lua.

## Optional application profiles

### Terminal and multiplexers

| Tool | Level | Notes |
| --- | --- | --- |
| Alacritty | Optional application | Uses the downloaded Catppuccin theme and the Maple Mono NF CN font. |
| Zellij | Optional application | Modern terminal multiplexer; it can be used instead of tmux. |
| tmux | Optional application | Uses TPM-managed plugins after `Prefix + I`. It does not need to be installed alongside Zellij. |
| htop | Recommended with tmux | The tmux `Prefix + ~` binding opens it. |
| reattach-to-user-namespace | Recommended with tmux on macOS | Used by the configured macOS clipboard binding. |

### Mail and debugging

| Tool | Level | Notes |
| --- | --- | --- |
| Neomutt | Optional | The repository has configuration but no dispatcher installer for it. |
| w3m | Recommended with Neomutt | Renders HTML mail as text. The current mailcap references `/usr/local/bin/w3m`, so that path must be adjusted on hosts where the executable lives elsewhere. |
| GDB | Optional | The repository has a standalone `gdb/gdbinit` but no dispatcher installer. |

## Installed automatically

Do not treat the following as host prerequisites:

- Powerlevel10k, zsh-autosuggestions and zsh-syntax-highlighting are cloned by
  the Zsh installer.
- lazy.nvim and the configured Neovim plugins are cloned by Neovim.
- Mason installs the selected LSP servers.
- nvim-treesitter installs the selected parsers; only its CLI and compiler are
  host prerequisites.
- The Alacritty installer downloads the Catppuccin theme files.
- The tmux installer clones TPM. Other tmux plugins are installed from inside
  tmux with `Prefix + I`.

Generated files live in the locations documented in `AGENTS.md` and should
not be copied between machines or committed.
