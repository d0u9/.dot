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
| Bash | Runs `bootstrap.sh`, `install.sh` and every `apps/*/app.sh`. |
| awk | Formats and parses shared shell command output. BSD awk and GNU awk are supported; the shortcuts use their common POSIX syntax and do not require installing GNU awk on macOS. |
| Git | Clones Zsh and Neovim plugin repositories, supplies the Bash prompt's repository status, and runs the shared Git shortcuts. `gpl`/`gpr` require Git 2.27+ (merge autostash control); `gsw`/`gswc` require Git 2.23+ (`git switch`). Upgrade older Linux distribution packages to use these shortcuts. macOS Command Line Tools supplies Git. |
| curl | Downloads Alacritty themes, resources used by editor tooling, and the official releases installed by `dgspkg`, which also needs `shasum` (macOS) or `sha256sum` (Linux) to verify them and `unzip` for zip archives. |
| tar | Extracts downloaded tools and archives; `pack` in both shells creates tar archives and uses gzip by default (supplied by macOS and standard Linux installations). |

Install the application whose configuration you plan to use. Bash, Zsh, Neovim,
Alacritty and Zellij are independent targets; installing one does not
require installing all of the others.

## Lightweight Bash server profile

| Tool | Level | What it enables |
| --- | --- | --- |
| Bash | Required for Bash | The server-oriented shell configuration and prompt. |
| bash-completion | Strongly recommended | Adds programmable completion for Git, SSH, package managers and other installed commands. With Homebrew, the installer checks Bash on `PATH`: Bash 4.2+ uses `bash-completion@2`, older Bash uses `bash-completion`. Linux package managers use `bash-completion`. Conflicting Homebrew versions must be removed manually before switching. |
| Docker | Optional | Enables the `dps`/`dpsa` aliases and the `dnets` (network to containers, addresses and ports), `dcnets` (container to networks), `dvols` (volume to containers) and `dcvols` (container to mounts), `dips` (container addresses and ports), `dsh` (shell in a container) and `dclean` (prune unused objects) commands in both shells. Without it the aliases are not defined and the commands print an error. |
| 7zz (7-Zip) | Optional, preferred for archives | `unpack` in both shells prefers `7zz` for automatic format detection, including 7z, zip, rar, cab, iso and arj. `./install.sh cli` installs the official build (`dgspkg install 7zz`), which includes the RAR codecs; Homebrew's `sevenzip` does not. Compressed tar archives are decompressed and then unpacked. `pack` falls back to p7zip's `7z` when `7zz` is missing. `pack -f 7z` requires one of them; `pack -f zip` prefers them, and `pack -p` needs them for AES-256 (without them, `pack -p -f zip` uses `zip -e`, weak ZipCrypto, with a warning). |
| unar | Optional, recommended for RAR | `unpack` uses `unar` (then `unrar`) for `.rar` before `7zz`, because Homebrew builds `7zz` without the RAR codecs and it fails with "Unsupported Method". macOS: `brew install unar`; Linux: package `unar`. |
| zip, unzip, 7z, unrar, gzip, bzip2, zstd, xz | Optional fallback | `pack` uses gzip/bzip2/xz for tar compression and zip for ZIP creation when `7zz` is unavailable. The extraction tools are used by `unpack` when `7zz` is unavailable; `tar`, `gunzip` and `bunzip2` cover the common formats. A missing tool makes `unpack` report that format as unsupported. |
| python3 | Optional | Runs the `serve` command (`python3 -m http.server`) in both shells. |

## Core Zsh and Neovim workstation

For the main shell and editor setup, install all of the following:

| Tool | Level | What it enables |
| --- | --- | --- |
| Zsh | Required for Zsh | The shell configuration, prompt and plugins. |
| Neovim 0.12+ | Required for Neovim | The editor configuration. `./install.sh nvim` installs the official build into `~/.local` on macOS and Linux (arm64 and x86_64); the Linux build needs a reasonably recent glibc and does not run on musl hosts such as Alpine; install the distribution package there (`apk add neovim`). |
| tree-sitter CLI | Required for Neovim | Builds the configured Tree-sitter parsers. The executable must be named `tree-sitter`. |
| C build toolchain | Strongly recommended for Neovim | Compiles Tree-sitter parsers; without it `./install.sh nvim` warns and skips them, leaving regex highlighting. Use Xcode Command Line Tools on macOS, `build-essential` on Debian/Ubuntu, or the distribution equivalent. |
| ripgrep (`rg`) | Strongly recommended | Powers fzf-lua live grep and fast project-wide searches. |
| fd | Strongly recommended | Gives fzf-lua a fast, convenient filesystem search backend. |
| eza | Strongly recommended | Replaces `ls` with colour and directory-first sorting. `./install.sh eza` installs it with the host package manager; checked by default on new hosts. No official macOS prebuilt release is available. `lss`, `lsc` and `lsl` are eza-only views; without eza they print an install hint. |
| jq | Optional | JSON processor. `./install.sh jq` or `dgspkg install jq` installs official macOS/Linux arm64/x86_64 binaries; checked by default on new hosts. Explicit versions use upstream tags such as `jq-1.8.2`. |
| fclones | Optional | Finds duplicate files by content across directories (`fclones group DIR...`). `./install.sh fclones` installs it with the host package manager; unchecked by default. No official macOS or arm64 prebuilt release is available. |
| aria2 (`aria2c`) | Optional | Resumable multi-connection HTTP/FTP and BitTorrent downloads behind `dl`, `dll` (URL list file), `dl1` (one connection) and `dlt` (torrent or magnet, no seeding). `./install.sh aria2` installs it with the host package manager; unchecked by default. No official macOS or Linux prebuilt release is available. Without it the aliases print an install hint. |
| tree | Optional fallback | Remains the native `tree` command when `eza` is unavailable. With `eza`, the shell instead defines `tree` as `eza --tree`; with neither tool, it defines no `tree` alias. |
| fzf | Strongly recommended | Adds shell history/file fuzzy search and ZLE key bindings. |
| zoxide | Strongly recommended | Provides ranked directory navigation through `z` and `zi`. |
| difftastic (`difft`) | Optional | Syntax-aware diff of two files or directories (`difft dirA dirB`). `./install.sh cli` installs it through `dgspkg`; the Linux arm64 build links glibc, x86_64 is static. |
| bottom (`btm`) | Optional | Terminal system and process monitor. `./install.sh cli` installs the official build through `dgspkg` (`dgspkg install btm`); macOS and Linux support arm64 and x86_64, with musl builds on Linux. |
| dgs-toolbox (`dgs`) | Optional | `./install.sh dgs` or `dgspkg install dgs` installs its official binary on macOS and Linux (arm64 and x86_64). The bootstrap checklist leaves this app unchecked until installed. |
| sing-box | Optional | `./install.sh sing-box` or `dgspkg install sing-box` installs the official proxy executable on macOS and Linux (arm64 and x86_64); unchecked by default. No proxy configuration or service is installed. |
| shadowsocks-rust | Optional | `./install.sh shadowsocks-rust` or `dgspkg install shadowsocks-rust` installs `sslocal`, `ssserver`, `ssmanager`, `ssservice` and `ssurl` together; macOS and Linux arm64/x86_64, using musl builds on Linux. Unchecked by default; no proxy configuration or service is installed. Its tar.xz archives require xz support in tar (Linux may need the `xz` or `xz-utils` package). |
| age | Optional | `./install.sh age` or `dgspkg install age` installs `age` and `age-keygen` together on macOS and Linux (arm64 and x86_64); unchecked by default. |
| rclone | Optional | `./install.sh rclone` or `dgspkg install rclone` installs the official single binary on macOS and Linux (arm64 and x86_64); unchecked by default. Its zip archives need `unzip`. `rclone mount` additionally needs FUSE: macFUSE or FUSE-T on macOS, fuse3 on Linux. No remote configuration is installed. |
| Maple Mono NF CN | Strongly recommended | Matches the configured Alacritty font and supplies Nerd Font glyphs used by Neovim. |

On macOS, Homebrew is the preferred package source. In particular, install
`tree-sitter-cli`, not the similarly named `tree-sitter` library formula.
`./install.sh zsh` installs `fzf` and `zoxide` through `dgspkg`, and
`./install.sh eza` installs eza through the host package manager. The other recommended tools remain
the host provisioner's responsibility.

## macOS GNU command layer

These packages are optional. The default-on `macos` installer profile installs
coreutils, diffutils and Bash completion through Homebrew on macOS only.
The shell safely falls back to the macOS system
commands, but installing them makes command behaviour more consistent with
Linux. Candidate selection is defined in `apps/zsh/core/aliases.zsh`.

| Package | Commands used by the configuration |
| --- | --- |
| coreutils | `gls`, `gdircolors`; installed by `./install.sh macos` through Homebrew on macOS only |
| diffutils | GNU diff tools such as `gdiff`; installed by the macOS-only Homebrew profile |
| bash-completion / bash-completion@2 | Version-appropriate Bash completions; installed by the macOS-only Homebrew profile without linking Bash configuration |
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
| C/C++ compiler (`cc`) | Makes the configuration request `clangd`. Completion also needs each project's `compile_commands.json`; clangd itself is a Mason prebuilt and needs no clang install. |
| Python | Supports Python development and the virtual-environment prompt segment. |
| Ruby | Supports Ruby development; the parser and editor settings themselves do not require a local Ruby runtime. |
| mise | Optional development-tool version manager. `./install.sh mise` installs the official build and global node, python and go; both shells put its shims directory on `PATH` instead of running `mise activate`, and the shims pick each project's versions when called. On musl hosts such as Alpine, mise has no prebuilt node and builds it from source, which needs python and a C++ toolchain. |
| Node.js/npm | Needed for JavaScript/TypeScript development, but not for the base editor bootstrap. |

Mason installs the configured language servers after the relevant toolchain
gate passes. `lua_ls` is always requested because it is distributed as a
prebuilt binary and the configuration itself is Lua.

## Optional application profiles

### SSH client

| Tool | Level | Notes |
| --- | --- | --- |
| OpenSSH client 7.3+ (`ssh`) | Required for the optional SSH profile | Uses `Include` to load removable client defaults, including connection multiplexing (`ControlMaster auto`, hashed control sockets in `~/.ssh`, and ten minutes of idle persistence). macOS supplies the client; on Linux install the distribution's OpenSSH client package (for example `openssh-client` on Debian/Ubuntu or `openssh-clients` on Fedora). `./install.sh ssh` installs configuration only, not the client or an SSH server. |

### Terminal and multiplexers

| Tool | Level | Notes |
| --- | --- | --- |
| Alacritty | Optional application | Uses the downloaded Catppuccin theme and the Maple Mono NF CN font. |
| Zellij | Optional application | Modern terminal multiplexer. |

## Installed automatically

Do not treat the following as host prerequisites:

- Powerlevel10k, zsh-autosuggestions and zsh-syntax-highlighting are cloned by
  the Zsh installer.
- lazy.nvim and the configured Neovim plugins are cloned by Neovim.
- Mason installs the selected LSP servers.
- nvim-treesitter installs the selected parsers; only its CLI and compiler are
  host prerequisites.
- The Alacritty installer downloads the Catppuccin theme files.

Generated files live in the locations documented in `AGENTS.md` and should
not be copied between machines or committed.
