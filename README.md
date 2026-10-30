# .dot
The bucket of dot files.

# Description

This repository contains configuration for Bash, Zsh, Neovim and other commonly
used applications. Private configuration lives in an independent repository so
that sensitive information is not added here.

**Setting up a new machine? Start with [DEPENDENCIES.md](DEPENDENCIES.md)** for
the required, strongly recommended and optional tools on macOS and Linux.

```
curl -fsSL https://raw.githubusercontent.com/d0u9/.dot/master/bootstrap.sh | bash
```

`bootstrap.sh` checks for git, curl, tar, xz and unzip, clones the repository into
`~/.dot` (or `$DOT_DIR`), or updates it, then opens a checklist of the apps
and their optional parts; ticking mise shows node, python and go below it.
Afterwards `./install.sh` manages the apps:

```
./install.sh                 # the checklist again (also -m)
./install.sh zsh mise:node   # install or update apps, choosing items
./install.sh -u              # update every installed app
./install.sh -r zellij       # uninstall, restoring any .bk backup
./install.sh -p nvim         # delete generated data (plugins, undo, ...)
./install.sh -l              # list apps, * = installed
```

---

# Content
- [Supported platforms](#supported-platforms)
- [Dependencies](#dependencies)
- [Prebuilt tools](#prebuilt-tools)
- [Private config files](#Private config files)
- [SSH](#ssh)
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
macOS and Linux columns in `apps/shell/fallbacks`, shared by both shells, to
add candidates or change priorities.
When `eza` is available, `tree` maps to `eza --tree`; otherwise an installed
standalone `tree` remains untouched, and no alias is created when both are
missing.
Both `vim` and `vi` use `nvim` when installed, otherwise their default commands.
`EDITOR` and `VISUAL` are set to the first installed of `nvim`, `vim` and `vi`,
replacing a lower-ranked value such as a distribution's `/usr/bin/vim` and
any editor the list does not name, such as `emacs` or `nano`. Existing values
are kept only while their executable is available.
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
the current one, manual pages it ships in a `manN` directory are linked into
`~/.local/share/man`, and the previous version stays for a switch back without a
download. Downloads are checked against the sha256 that GitHub records.
Each app installs the tools it needs; `./install.sh cli` installs `rg`, `fd`,
`7zz`, `tree-sitter`, `difft` and `btm`.

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
| [difftastic](https://github.com/Wilfred/difftastic) | `difft` | latest | syntax-aware diff of files and directories |
| [bottom](https://github.com/ClementTsang/bottom) | `btm` | latest | terminal system and process monitor |
| [dgs-toolbox](https://github.com/d0u9/dgs-toolbox) | `dgs` | latest | dgs command-line tool |
| [sing-box](https://github.com/SagerNet/sing-box) | `sing-box` | latest | proxy tool |
| [shadowsocks-rust](https://github.com/shadowsocks/shadowsocks-rust) | `sslocal`, `ssserver`, `ssmanager`, `ssservice`, `ssurl` | latest | Shadowsocks client and server tools |
| [age](https://github.com/FiloSottile/age) | `age`, `age-keygen` | latest | file encryption and key generation |
| [jq](https://github.com/jqlang/jq) | `jq` | latest | JSON processor (explicit tags: `jq-1.8.2`) |
| [mise](https://github.com/jdx/mise) | `mise` | latest | language runtimes, through its shims |
| [eza](https://github.com/eza-community/eza) | `eza` | latest | `ls` replacement; Linux only, Homebrew on macOS |

Each tool has a recipe in `apps/release/recipes/`. A VERSION is a tag (with
or without its leading `v`) or a channel; the last one requested is saved in
`~/.local/lib/<tool>/channel` and followed by later upgrades. Common commands,
each with a short form:

```
dgspkg list -u             # ls: installed and target versions, update status
dgspkg install fd v10.5.0  # i:  one tool at a version or channel
dgspkg upgrade             # up: every installed tool, along its channel
dgspkg versions nvim       # v:  versions on disk, * = current
dgspkg versions -r nvim    #     channels and recent upstream releases
dgspkg uninstall fd        # rm: remove the tool and its link
```

Install optional tools with `dgspkg install NAME` or `./install.sh NAME`:
`dgs`, `sing-box`, `shadowsocks-rust` and `age` have independent apps that
start unchecked in the bootstrap checklist. Once recorded as installed,
they start checked for updates. Multi-command packages share one download,
version and upgrade/uninstall operation. Proxy apps install executables only;
configuration and service startup remain the host's responsibility.

To add a tool with an official release, write `apps/release/recipes/<tool>.sh`
(a GitHub repository, the executable inside the archive, and the asset name
for each platform) and add a line to the list. A recipe can set
`release_links=(COMMAND:BIN ...)` to expose multiple executables, or
`release_format=binary` for a single uncompressed executable. Tools without official binaries
for both platforms, such as eza on macOS, stay with the package manager.

`./install.sh eza` installs the official eza build on Linux and uses Homebrew
on macOS, where no official build exists; eza and jq
start checked on new hosts. `./install.sh fclones` and `./install.sh aria2`
install those tools the same way but start unchecked. On macOS, the
default-on `macos` profile installs
Homebrew's coreutils, diffutils and version-appropriate Bash completion.
That profile installs nothing on Linux and starts unchecked there.

---

# Private config files

If you have any private files(files containe sensitive contents), you may gather all of them together and put them in the `conf` directory. The `conf` directory has been added in `gitignore` file, which won't be pushed to the server.

---

# SSH

`./install.sh ssh` links the public client defaults to `~/.ssh/config.d/00-dot.conf`.
This optional app starts unchecked and uses the host's existing OpenSSH client;
it does not install SSH or change `/etc/ssh/`.

If `~/.ssh/config` does not exist, the installer creates it with this line.
Otherwise, it leaves the existing file or symlink untouched; add the line
manually at the beginning if these defaults should take priority:

```sshconfig
Include ~/.ssh/config.d/00-dot.conf
```

Only our fragment is included; other files in `config.d` are not enabled by
this entry. Most SSH options use the first obtained value. Put host-specific
exceptions before this Include if they should win. The defaults probe an idle
connection after 60 seconds, disconnect after three unanswered probes, set a 15-second
connection timeout, and send `COLORTERM` when present. The server must accept
`COLORTERM` for it to reach remote applications; this alone does not guarantee
truecolor support.

Connection multiplexing is enabled with `ControlMaster auto` and
`ControlPersist 10m`: subsequent sessions reuse a master connection, which
stays available for ten minutes after the last session closes. Control sockets
use `~/.ssh/cm-%C`; the hash keeps names short and distinguishes connection
targets. Keep `~/.ssh` private to the account (mode 700). No extra socket
directory or setup command is needed. This also applies to Git over SSH,
scp and sftp when they use this client configuration.

To disable sharing for one invocation, use `ssh -S none host-a`. For a
persistent host exception, put this before the Include, then restore the
global scope:

```sshconfig
Host host-a
    ControlMaster no
    ControlPath none
Host *
    Include ~/.ssh/config.d/00-dot.conf
```

Delete `~/.ssh/config.d/00-dot.conf`, or run `./install.sh -r ssh`, to disable the layer.
The Include can stay: a missing file is ignored, and previous configuration
values apply again to new connections. Existing connections are unaffected.
Keys, `known_hosts`, private host definitions and the existing main config are
not managed by this app; it declares no purgeable data.

Installation refuses an existing `00-dot.conf` unless it is already the same
managed symlink. It never replaces or backs up a foreign file or symlink,
and uninstallation leaves any unrelated `.bk` file untouched.

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
./install.sh nvim
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

Plugin versions are not pinned across hosts: lazy.nvim's lockfile is
written to `apps/nvim/runtime/lazy-lock.json` and only records this host's
last sync. Everything a plugin writes lives under `apps/nvim/runtime/`, which is gitignored and can be deleted to rebuild from
scratch.

**[`apps/nvim/doc/install.md`](apps/nvim/doc/install.md) is the reference**:
what the installer does on its own, what has to be on the host first (the
tree-sitter CLI in particular), and where to add a plugin, an LSP server or a
parser.

---

# Zsh

Run `./install.sh zsh` to install fzf and zoxide through `dgspkg`, update
the three Zsh plugins, and link `apps/zsh/zshrc` to `~/.zshrc`. Powerlevel10k uses an already-installed, version-compatible
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
ones available on the current host in a `Section / Command / Description`
table, including a purpose description for each managed alias. A function
whose required tool is missing, or that is defined only on Linux, is left
out. `dgscmds -l` or `dgscmds SECTION...` shows full usage and alias expansions;
section names are case-insensitive.

Check the command parsers without loading private hooks or contacting services:
`bash apps/shell/test-commands.sh "$PWD/apps/shell/lib.sh"`, or run the same
script with `zsh -f`. An optional second argument selects an absolute awk
executable, so the fixtures can be checked with both BSD awk and GNU awk.

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
| Git | `gpl [REMOTE]` | pull the current branch from `origin` (or REMOTE), fast-forward only |
| Git | `gpr [REMOTE]` | pull the current branch from `origin` (or REMOTE), rebasing local commits |
| Git | `gps [--dry-run] [REMOTE]` | push only the current branch to the same name on `origin` (or REMOTE) |
| Git | `gpsu [--dry-run] [REMOTE]` | push the current branch and set its upstream |
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
| Files | `cptime [-r] SRC TARGET...` | copy the times of SRC to files and directories, `-r` recursively |
| Files | `serve [PORT]` | share this directory over HTTP (default 8000, needs python3) |

The Git sync helpers resolve the branch each time they run, including branch
names containing `/`. They reject detached HEADs, branches without a first
commit, and calls outside a working tree. They use explicit full branch refs,
so an upstream pointing elsewhere, `push.default`, configured push refspecs,
or a tag with the same name cannot redirect the branch operation. A missing
remote or remote branch reports Git's normal error; no fallback remote is
chosen. `gpl` stops on divergence; use `gpr` when you want to rebase local
commits. Both pull helpers require Git 2.27+ and disable automatic stashing.
`gps` can publish a new branch without changing its upstream; use `gpsu` to
set or replace the upstream explicitly. Pushes do not force updates or
automatically follow tags.
For example, `gps --dry-run` previews a push and `gpl upstream` pulls the
same-named branch from the `upstream` remote. These helpers accept only the
documented arguments; use `git` (or `g`) for other options and refspecs.

Both shells also define these aliases when Git is installed. They forward
arguments directly to Git:

| Alias | Expansion |
| --- | --- |
| `g` | `git` |
| `gst`, `gss` | `git status`, `git status --short` |
| `ga`, `gc` | `git add`, `git commit` |
| `gf` | `git fetch` (Git's configured default remote, or pass one explicitly) |
| `gsw`, `gswc` | `git switch`, `git switch -c` (Git 2.23+) |
| `gb` | `git branch -vv` |
| `glog` | `git log --oneline --decorate -12` |
| `glg` | colored history graph across all local and remote-tracking branches, with refs, commit subjects, authors and relative dates |
| `gd`, `gds` | working-tree / staged diff, using difftastic when available |
| `gdv`, `gdvs` | working-tree / staged diff in nvimdiff |

`glg` uses Git's normal pager (`q` to quit) and supports log options such as
`glg -30` or `glg --since="2 weeks ago"`. Colors are automatic and omitted
when output is redirected. Remote-tracking branches reflect the last fetch;
run `gf --all` first when you want to refresh them.

Use `dgscmds git` for the available Git shortcuts. After updating the checkout,
open a new shell, or source `"$DOT_DIR/apps/shell/lib.sh"` and your shell's
alias file (`"$DOT_ZSH_DIR/core/aliases.zsh"` or
`"$DOT_BASH_DIR/aliases.bash"`) to refresh an existing session.

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

Run `./install.sh bash` for the lightweight server shell profile. It links
`apps/bash/bashrc` and `apps/bash/bash_profile` into the home directory, tries
to install `bash-completion` (Homebrew uses `bash-completion@2` when Bash on
`PATH` is 4.2+), adds listing and navigation aliases, puts mise's
shims on `PATH`, loads zoxide and fzf when installed, and enables case-insensitive menu
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
