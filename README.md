# .dot
The bucket of dot files.

# Description

This repo includes configuration files come from various most common used softewares, such as neovim, oh-my-zsh, tmux or private applications(this private configuration is managed by an independent git repo, and won't be added in this repo to avoid sensitive information leakage). Each application's specific configuration files are contained in one directory which named as the application's name.

---

# Content
- [Supported platforms](#supported-platforms)
- [Prerequisite](#prerequisite)
- [Private config files](#Private config files)
- [Package manager history](#package-manager-history)
- [NeoVim](#neovim)
- [oh-my-zsh](#oh-my-zsh)
- [tmux](#tmux)

# Supported platforms

Unless a file says otherwise in an explicit code branch, every configuration
here is meant to run unchanged on:

- **Linux**, on any architecture
- **macOS**, on both `x86_64` (Homebrew under `/usr/local`) and `arm64`
  (Homebrew under `/opt/homebrew`)

Anything that cannot hold to that has to be isolated behind one of the two
mechanisms below, never inlined into a shared file.

## Where platform differences belong

| Scope | Location | In git |
| --- | --- | --- |
| OS-specific | `apps/omz/macos/`, `apps/omz/linux/` | yes |
| Machine-specific | `apps/omz/host-conf/*-{pre,post}.sh` | no, gitignored |

`omz-pre.sh` and `omz-post.sh` dispatch on `$OSTYPE` into the first, then
source anything found in the second. A path, prefix or tool that only exists
on one host belongs in `host-conf`, not in a tracked file.

## Rules for shared files

These follow from portability bugs that have already been fixed here once:

- **Never hardcode a Homebrew prefix.** Use `$HOMEBREW_PREFIX`, which
  `brew shellenv` exports, or probe `/opt/homebrew` *before* `/usr/local` —
  a machine can carry both an arm64 Homebrew and a Rosetta one, and probing
  in the other order silently selects the Rosetta toolchain on Apple Silicon.
- **Guard every optional tool** with `command_exist`, so a host that lacks it
  starts a clean shell instead of printing errors. The same applies to
  optional oh-my-zsh plugins and themes, which need a directory test before
  they are enabled.
- **Do not assume one install layout.** `nvm`, for example, ships as
  `$NVM_DIR/nvm.sh` with completion at `$NVM_DIR/bash_completion` when
  installed from git, but as `$HOMEBREW_PREFIX/opt/nvm/nvm.sh` with
  completion under `etc/bash_completion.d/nvm` when installed from Homebrew.
  Probe for both.
- **Guard anything that needs a terminal**, such as `stty`, with `[ -t 0 ]`.
  These files are also sourced by non-interactive shells.
- **Do not export `TERM`.** Overriding it with `xterm-256color` discards
  capabilities the real terminal advertises, such as undercurl. For an old
  remote host that lacks the local terminfo entry, install it there instead:
  `infocmp "$TERM" | ssh remote 'tic -x -'`.

## Known limitations

- GNU coreutils are assumed by the install scripts, not by the shell config.
  On macOS `install.sh` requires `grealpath` from `brew install coreutils`
  and aborts early without it.
- Homebrew on Linux is only detected at `/home/linuxbrew/.linuxbrew`, the
  default prefix. A per-user Linuxbrew install needs a `host-conf` entry.
- `nvm.sh` is not sourced at startup, since it costs well over a second.
  The default version is resolved by walking the alias files under
  `$NVM_DIR/alias` and its `bin` directory is put on `PATH` directly, so
  every globally installed binary is available in a fresh shell. Only the
  `nvm` command itself is a stub that sources the script on first use. If
  the alias chain cannot be resolved, the config falls back to sourcing
  `nvm.sh` at startup and takes the slower path. `.nvmrc` auto-switching on
  `cd` is not wired up.
- Changes are routinely exercised on macOS only. The Linux paths are kept
  correct by inspection, so treat a first run on a new Linux host as
  unverified.

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
| [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) | zsh plugins | 2015-11-26 | `9a74de3` |
| [tpm](https://github.com/tmux-plugins/tpm) | tmux plugins | 2015-12-20 | `ac272b7` |
| [pyenv](https://github.com/pyenv/pyenv) | python versions | 2016-04-18 | `26e29a3` |
| [Homebrew](https://brew.sh) | macOS packages | 2021-04-30 | `1ba93ce` |
| [rbenv](https://github.com/rbenv/rbenv) | ruby versions | 2023-05-09 | `0a7f67e` |
| [mason.nvim](https://github.com/mason-org/mason.nvim) | LSP servers | 2023-07-12 | `78e18c3` |
| [nvm](https://github.com/nvm-sh/nvm) | node versions | 2026-08-21 | `3ea7f45` |

The version managers are all loaded from `apps/omz/`, each behind a
`command_exist` guard, so a host that lacks one still starts a clean shell.

---

# NeoVim

> If you are a man occasionally understands Chinese, you may check this [article](http://www.d0u9.xyz/neovim-pei-zhi-yu-cha-jian-shuo-ming/) which is posted on my blog for more details.

## Install NeoVim

You may check [here](https://github.com/neovim/neovim/wiki/Installing-Neovim).

## Create configuration directory

Instead of `.vimr` and `.vim/` dir, neovim uses the XDG specification to manage its configuration files.

To use my configurations, all you need is to link the `nvim` dir in my `.dot` to where the XDG specification designates.

```
mkdir -p ${XDG_CONFIG_HOME:=$HOME/.config}
ln -s .dot/nvim $XDG_CONFIG_HOME/
```

[Here](https://neovim.io/doc/user/nvim_from_vim.html) gives more information about the differences between vim and neovim.


## Install python support of Neovim

```
pip install neovim
```

or, if you familiar with python3 use `pip3` instead.

If you are using OSX El capitan, like me, and have failed installing pip, you have to understand the new protect mechanism, i.e. [SIP](https://en.wikipedia.org/wiki/System_Integrity_Protection).


## Install the plugins

Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim). It
bootstraps itself: `init.lua` clones lazy on the first start, and lazy then
installs everything listed in `apps/nvim/plugins/install.lua`. Nothing has to
be installed by hand.

- `:Lazy` opens the plugin manager UI, `:Lazy sync` installs and updates.
- `apps/nvim/lazy-lock.json` pins the exact commit of every plugin and is
  tracked in git, so all hosts converge on the same versions. Commit it after
  a `:Lazy sync`.
- LSP servers are installed by `:Mason`.
- tree-sitter parsers are listed in
  `apps/nvim/plugins/configs/treesitter-languages.lua` and installed on
  startup; `:TSUpdate` refreshes them. This needs the tree-sitter CLI in
  `$PATH` -- on macOS that is the `tree-sitter-cli` formula, **not**
  `tree-sitter`, which ships only the library.

Everything a plugin writes lives under `apps/nvim/runtime/`, which is
gitignored — the clones themselves under `runtime/plugins/lazy/`.

---

# oh-my-zsh

1. Copy theme to your oh-my-zsh configuration directory.
2. Make a symbol of zshrc to your ~ directory.

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
