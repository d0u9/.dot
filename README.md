# .dot
The bucket of dot files.

# Description

This repository contains configuration for Zsh, Neovim, tmux and other commonly
used applications. Private configuration lives in an independent repository so
that sensitive information is not added here.

---

# Content
- [Supported platforms](#supported-platforms)
- [Prerequisite](#prerequisite)
- [Private config files](#Private config files)
- [Package manager history](#package-manager-history)
- [NeoVim](#neovim)
- [Zsh](#zsh)
- [tmux](#tmux)

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
The disconnected `host-conf/` directory remains as the host-local entry point
for private configuration. Zsh's completion functions, including `_git`,
retain their native autoload-on-first-use behavior. Interactive aliases prefer
installed `g`-prefixed GNU tools and otherwise retain the platform commands.
Zoxide provides `z` and `zi`; fzf shell integration supports both its current
`--zsh` interface and the separate scripts shipped by older packages.

---

# Prerequisite

To obtain the full features of this configuration, you have to install NERD fonts which are patched lots of icons.

You can find more details of NERD fonts here: [https://github.com/ryanoasis/nerd-fonts](https://github.com/ryanoasis/nerd-fonts)

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
| [tpm](https://github.com/tmux-plugins/tpm) | tmux plugins | 2015-12-20 | `ac272b7` |
| [Homebrew](https://brew.sh) | macOS packages | 2021-04-30 | `1ba93ce` |
| [mason.nvim](https://github.com/mason-org/mason.nvim) | LSP servers | 2023-07-12 | `78e18c3` |

---

# NeoVim

> If you are a man occasionally understands Chinese, you may check this [article](http://www.d0u9.xyz/neovim-pei-zhi-yu-cha-jian-shuo-ming/) which is posted on my blog for more details.

## Install NeoVim

You may check [here](https://github.com/neovim/neovim/wiki/Installing-Neovim).

## Install this configuration

```
./install.sh -i nvim
```

That symlinks `apps/nvim` to `$XDG_CONFIG_HOME/nvim` (neovim uses the XDG
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

---

# tmux

## Make symbol link

Link `tmux` dir and `tmux.conf` to your home directory:

```
ln -s /path/to/.dot/tmux ~/.tmux
ln -s /path/to/.dot/tmux/tmux.conf ~/.tmux.conf
```

## Install tpm plugin

The official installation guide can be found [https://github.com/tmux-plugins/tpm#installation](https://github.com/tmux-plugins/tpm#installation).

Simply:

```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

## Install other plugins

Launch tmux and press the shortcut: `Prefix + I`.

---

# License
![CC License](http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png)
