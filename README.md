# .dot
The bucket of dot files.

# Description

This repository contains configuration for Bash, Zsh, Neovim and other commonly
used applications. Private configuration lives in an independent repository so
that sensitive information is not added here.

**Setting up a new machine? Start with [DEPENDENCIES.md](DEPENDENCIES.md)** for
the required, strongly recommended and optional tools on macOS and Linux.

---

# Content
- [Supported platforms](#supported-platforms)
- [Dependencies](#dependencies)
- [Prebuilt tools](#prebuilt-tools)
- [Private config files](#Private config files)
- [Package manager history](#package-manager-history)
- [NeoVim](#neovim)
- [Zsh](#zsh)
- [Bash](#bash)

# Supported platforms

Unless a file says otherwise in an explicit code branch, every configuration
here is meant to run unchanged on:

- **Linux**, on any architecture
- **macOS**, on both `x86_64` (Homebrew under `/usr/local`) and `arm64`
  (Homebrew under `/opt/homebrew`)

The Zsh configuration keeps a small explicit set of interactive additions:
Powerlevel10k, autosuggestions, syntax highlighting, fzf shell integration and
zoxide. Top-level pre and post hook phases remain so behavior can be added back
one piece at a time, while the implementation lives under `apps/zsh/core/`.
Optional readable files or symlinks in `host-conf/` are loaded when they end
in `-pre.sh`, `-pre.zsh`, `-post.sh` or `-post.zsh`. Their prefixes only
control lexical load order; files with other suffixes are ignored. Zsh's
completion functions, including `_git`, retain their native autoload-on-first-use
behavior. Interactive aliases prefer
modern replacements such as `eza`; on macOS they next try `g`-prefixed GNU
tools, while Linux falls directly back to default commands. Edit the ordered
`macos_fallbacks` and `linux_fallbacks` lists in `apps/zsh/core/aliases.zsh`
to add candidates or change priorities.
When `eza` is available, `tree` maps to `eza --tree`; otherwise an installed
standalone `tree` remains untouched, and no alias is created when both are
missing.
Both `vim` and `vi` use `nvim` when installed, otherwise their default commands.
Zoxide provides `z` and `zi`; fzf shell integration supports both its current
`--zsh` interface and the separate scripts shipped by older packages.

---

# Dependencies

See **[DEPENDENCIES.md](DEPENDENCIES.md)** before provisioning a new macOS or
Linux machine. It separates hard prerequisites from strongly recommended shell
and editor tools, language-specific toolchains, and optional application
profiles.

For the intended visual experience, install Maple Mono NF CN. It includes the
Nerd Font glyphs used by the configured prompt, editor and terminal status
lines.

---

# Prebuilt tools

`dgspkg` installs command-line tools from their official prebuilt releases on
macOS and Linux (arm64 and x86_64), with no package manager. Each version is
unpacked whole under `~/.local/lib/<tool>/`, `~/.local/bin/<tool>` links to
the current one, and the previous version stays for a switch back without a
download. Downloads are checked against the sha256 that GitHub records.
`./install.sh -i release` runs `dgspkg sync` once.

| Tool | Command | Default | Purpose |
| --- | --- | --- | --- |
| [Neovim](https://github.com/neovim/neovim) | `nvim` | `stable` (also `latest`, `nightly`) | the editor |
| [7-Zip](https://github.com/ip7z/7zip) | `7zz` | latest | archives for `pack`/`unpack`, including RAR |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | `rg` | latest | content search, fzf-lua live grep |
| [fd](https://github.com/sharkdp/fd) | `fd` | latest | file search for fzf-lua |
| [fzf](https://github.com/junegunn/fzf) | `fzf` | latest | fuzzy finder and shell key bindings |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `zoxide` | latest | `z`/`zi` directory jumping |
| [tree-sitter CLI](https://github.com/tree-sitter/tree-sitter) | `tree-sitter` | latest | builds Neovim's parsers |
| [Zellij](https://github.com/zellij-org/zellij) | `zellij` | latest | terminal multiplexer |

The list lives in `apps/release/tools`, one `NAME [VERSION]` per line; a
VERSION is a tag (with or without its leading `v`) or a channel. Common
commands, each with a short form:

```
dgspkg sync                # s:  install or upgrade everything listed
dgspkg list -u             # ls: installed and target versions, update status
dgspkg install fd v10.5.0  # i:  one tool at a version or channel
dgspkg upgrade nvim        # up: same as install
dgspkg versions nvim       # v:  versions on disk, * = current
dgspkg versions -r nvim    #     channels and recent upstream releases
dgspkg uninstall fd        # rm: remove the tool and its link
```

To add a tool with an official release, write `apps/release/recipes/<tool>.sh`
(a GitHub repository, the executable inside the archive, and the asset name
for each platform) and add a line to the list. Tools without official binaries
for both platforms, such as eza on macOS, stay with the package manager.

---

# Private config files

If you have any private files(files containe sensitive contents), you may gather all of them together and put them in the `conf` directory. The `conf` directory has been added in `gitignore` file, which won't be pushed to the server.

---

# Package manager history

Every package, plugin and runtime manager these configs have been through,
oldest first. The two vim-side rewrites in particular mean old commits will
not make sense against the current layout.

## Editor plugin managers

| Manager | Adopted | Retired | Commit |
| --- | --- | --- | --- |
| [Vundle](https://github.com/VundleVim/Vundle.vim) (vim) | 2015-11-11 | 2015-12-17 | `b3cf3e9` → `7c21121` |
| [vim-plug](https://github.com/junegunn/vim-plug) | 2015-11-26 | 2017-04-05 | `9535b5c` → `7623005` |
| [dein.vim](https://github.com/Shougo/dein.vim) | 2017-04-05 | 2021-08-27 | `7623005` → `82933a4` |
| [packer.nvim](https://github.com/wbthomason/packer.nvim) | 2021-08-27 | 2026-09-02 | `82933a4` → `a2c06d4` |
| [lazy.nvim](https://github.com/folke/lazy.nvim) | 2026-09-02 | in use | `a2c06d4` |

Vundle went with the `.vimrc` when the repo dropped plain vim for neovim.
The move to packer came with neovim 0.5.0, in the same commit that replaced
`init.vim` with `init.lua`; the dead vim-plug and dein list survived as
`plugin_list_deprecated.vim` until `bfe90e9` (2023-05-11). The move to lazy
was made because packer is no longer maintained.

## Other managers still in use

| Manager | Manages | Adopted | Commit |
| --- | --- | --- | --- |
| [Homebrew](https://brew.sh) | macOS packages | 2021-04-30 | `1ba93ce` |
| [mason.nvim](https://github.com/mason-org/mason.nvim) | LSP servers | 2023-07-12 | `78e18c3` |

---

# NeoVim

> If you are a man occasionally understands Chinese, you may check this [article](http://www.d0u9.xyz/neovim-pei-zhi-yu-cha-jian-shuo-ming/) which is posted on my blog for more details.

## Install NeoVim

`dgspkg install nvim` installs the official build into `~/.local`, following
the `stable` channel; `dgspkg install nvim nightly` switches to the nightly
build. See [Prebuilt tools](#prebuilt-tools). Other installation methods are
listed [here](https://github.com/neovim/neovim/wiki/Installing-Neovim).

## Install this configuration

```
./install.sh -i nvim
```

That symlinks `apps/nvim` to `$HOME/.config/nvim` (neovim uses the XDG-style
layout rather than vim's `.vimrc` and `.vim/`) and bootstraps the plugins,
LSP servers and tree-sitter parsers. Re-running it is safe.

[Here](https://neovim.io/doc/user/nvim_from_vim.html) gives more information
about the differences between vim and neovim.


## Plugins

Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim), which
`init.lua` clones on the first start; the spec is
`apps/nvim/plugins/install.lua` and per-plugin settings live in
`apps/nvim/plugins/configs/`. `:Lazy` opens the manager, `:Lazy sync`
installs and updates.

`apps/nvim/lazy-lock.json` pins the exact commit of every plugin and is
tracked in git, so all hosts converge on the same versions -- commit it after
a `:Lazy sync`. Everything else a plugin writes lives under
`apps/nvim/runtime/`, which is gitignored and can be deleted to rebuild from
scratch.

**[`apps/nvim/doc/install.md`](apps/nvim/doc/install.md) is the reference**:
what the installer does on its own, what has to be on the host first (the
tree-sitter CLI in particular), and where to add a plugin, an LSP server or a
parser.

---

# Zsh

Run `./install.sh -i zsh` to install fzf, zoxide and the three Zsh plugins,
then link `apps/zsh/zshrc` to `~/.zshrc`. The installer supports Homebrew,
apt, dnf, pacman and apk; existing commands and correct plugin checkouts are
left in place. Powerlevel10k uses an already-installed, version-compatible
gitstatusd when available and otherwise falls back to Zsh's built-in
`vcs_info`; shell startup never downloads the binary. Both modes keep the
instant prompt: a fallback shell discards a prompt cache left behind by a
gitstatus installation that no longer works on this host, rather than giving
up the instant prompt on the hosts that benefit from it most.

Both Bash and Zsh provide `pack [-f FORMAT] [-o FILE] DIR`, defaulting to
`DIR.tar.gz` beside the directory without overwriting an existing archive.
Formats include tar, tar.gz, tar.bz2, tar.xz and zip; 7z requires `7zz`.
Output must be outside the source directory. `unpack [-d DIR] FILE...` unpacks
archives into the current directory (or creates the specified `-d` directory), preferring an executable `7zz` for format
detection and broader format support, with extension-based tools as fallback; use
`pack --help` or `unpack --help` for usage. Directory archives preserve file
and directory modification times within the format's timestamp precision;
creation and metadata-change times are not guaranteed.

The shell fetches the current branch's upstream remote in the background at
most once every five minutes per worktree. Set `DOT_GIT_AUTOFETCH_INTERVAL=0`
before loading Zsh to disable this, or set another interval in seconds.
Background fetch updates remote-tracking refs. When force-pushing with
`--force-with-lease`, also use `--force-if-includes` (or configure
`push.useForceIfIncludes=true`) to protect commits fetched in the background.

Before completion and tool setup, `core/shell.zsh` loads `core/homebrew.zsh`
to initialize an executable Homebrew using `brew shellenv zsh`. The prefix is
resolved once in `apps/shell/lib.sh`, which both shells source, and exposed as
`$DOT_BREW_PREFIX`: `/opt/homebrew` for macOS ARM, `/usr/local` for macOS Intel
(including Rosetta shells), and `/home/linuxbrew/.linuxbrew` for Linux on Intel
or ARM. Linux also checks the older `~/.linuxbrew` prefix; all platforms fall
back to an executable `brew` on PATH for custom installations. Missing or
non-executable installations are skipped.

`shellenv`'s output is cached like the other tool initializations, keyed on the
brew executable's resolved path, size and modification time. It does not depend
on the incoming shell environment: the environment-sensitive parts are deferred
expansions such as `${PATH+:$PATH}`, which the cached text expands when it is
sourced. Removing that fork took interactive startup from about 220ms to about
170ms on an Intel Mac.

Other tool initialization is cached by executable identity and command arguments.
Argument boundaries are preserved in the cache key, and cached command paths
are checked for executability so uninstalling a tool takes effect immediately.
GNU `dircolors` (including Homebrew's `gdircolors`) also keys its cache on
`TERM` and `COLORTERM`, so shells using different terminals get the right
palette. Failed initialization preserves the existing zoxide hook without
wrapping it again. Powerlevel10k reloads after all local prompt settings have
been applied.

Run `zsh -f tests/zsh-regression.zsh` for isolated regression checks; these
use temporary caches and stub tools and do not load private configuration.

---

# Shell commands

Both shells load these helpers from `apps/shell/lib.sh`. `dgscmds` lists the
ones available on the current host -- a command whose required tool is
missing, or that is defined only on Linux, is left out -- and `dgscmds -l` or
`dgscmds SECTION...` shows them in full.

| Section | Command | Purpose |
| --- | --- | --- |
| Network | `ports [-s] [-t\|-u\|-a] [-o KEY]` | listening sockets as one sortable table |
| Network | `killport [-s] [-y] [-9] PORT` | stop the processes listening on PORT, after asking |
| Network | `ips [local\|public]` | local interface addresses, or public IPv4/IPv6 |
| Network | `myip` | public IPv4 and IPv6 (`ips public`, needs curl) |
| Process | `psg PATTERN` | processes whose command line matches |
| Process | `topmem [N]` | top N processes by resident memory |
| System | `sysinfo` | OS, CPU, memory, disk, uptime and load |
| System | `dfh` | disk usage of real filesystems only |
| System | `svc [--user] [ACTION] [UNIT]` | systemctl and journalctl shortcuts (Linux) |
| System | `sudo_nopasswd [on\|off\|status]` | toggle passwordless sudo for this user (Linux) |
| System | `dgspkg COMMAND` | install and upgrade official prebuilt releases, see [Prebuilt tools](#prebuilt-tools) |
| Docker | `dnets`, `dcnets` | networks as trees of containers, and the reverse |
| Docker | `dvols`, `dcvols` | volumes as trees of mounting containers, and the reverse |
| Docker | `dips [container...]` | containers with network, IPv4 and ports |
| Docker | `dsh NAME [COMMAND...]` | shell (bash, else sh) in a running container |
| Docker | `dclean [-v] [-y]` | show and prune unused containers, images and cache |
| Files | `mkcd DIR` | create DIR and cd into it |
| Files | `lns [-afp] TARGET LINK` | symlink by shortest relative path, `-a` absolute |
| Files | `lnmv [-afp] LINK... DEST` | move symlinks without breaking them |
| Files | `pack`, `unpack` | create and extract archives, see the Zsh section |
| Files | `bak FILE...` | copy to `FILE.bak.<timestamp>` |
| Files | `serve [PORT]` | share this directory over HTTP (default 8000, needs python3) |

`lns [-afp] TARGET LINK` creates a symlink through the shortest relative path
from the link's directory to TARGET, so the pair keeps working when their
common tree moves; `-a` uses the absolute path instead. Both paths are taken
relative to the current directory, so `lns a/b/1 x/y/z` creates
`x/y/z -> ../../a/b/1`. `lnmv [-afp] LINK... DEST` moves symlinks without
breaking them: each one is recreated at its destination pointing at the same
target, an absolute link stays absolute, and the old link is removed only
after the new one exists. In both, `-f` replaces an existing destination and
`-p` creates missing parent directories; see `lns --help` or `lnmv --help`.

---

# Bash

Run `./install.sh -i bash` for the lightweight server shell profile. It links
`apps/bash/bashrc` and `apps/bash/bash_profile` into the home directory, tries
to install `bash-completion`, adds listing and navigation aliases, activates
mise, zoxide and fzf when installed, and enables case-insensitive menu
completion and prefix history search. Existing `~/.local/bin` and
`~/.local/bin/scripts` directories join `PATH`; `~/.local/share/man` joins
`MANPATH`, and `~/.local/lib` joins `LD_LIBRARY_PATH` on Linux. The single-line
prompt highlights `user@host`, the current directory and failed exit statuses. In Git repositories,
it also shows the branch (or detached commit), `*` for changes, and `⇡` / `⇣`
when ahead of or behind the upstream branch. It uses plain text when the
terminal does not support colour.

Optional readable files or symlinks in `apps/bash/host-conf/` are loaded when
they end in `-pre.sh` (before the aliases, completion, integrations and prompt)
or `-post.sh` (after the prompt), in lexical order; they are ignored by the
public repository. To show a chosen ID after `@` instead of the hostname, set
`DOT_PROMPT_HOST` in a pre hook:

```sh
echo 'DOT_PROMPT_HOST=prod-db1' > apps/bash/host-conf/10-host-pre.sh
```

---

# License
![CC License](http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png)
