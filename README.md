# .dot
The bucket of dot files.

# Description

This repo includes configuration files come from various most common used softewares, such as neovim, oh-my-zsh, tmux or private applications(this private configuration is managed by an independent git repo, and won't be added in this repo to avoid sensitive information leakage). Each application's specific configuration files are contained in one directory which named as the application's name.

---

# Content
- [Supported platforms](#supported-platforms)
- [Prerequisite](#prerequisite)
- [Private config files](#Private config files)
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
- `nvm` is loaded lazily: `nvm`, `node`, `npm` and `npx` are stubs that
  source `nvm.sh` on first use, which keeps shell startup near 0.6s instead
  of 2s. Other Node-adjacent commands such as `yarn`, `pnpm` and `corepack`
  are not stubbed, so they only work once one of the four above has run.
  `.nvmrc` auto-switching on `cd` is not wired up and would conflict with
  this scheme.
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

# NeoVim

> If you are a man occasionally understands Chinese, you may check this [article](http://www.d0u9.xyz/neovim-pei-zhi-yu-cha-jian-shuo-ming/) which is posted on my blog for more details.

## Install NeoVim

You may check [here](https://github.com/neovim/neovim/wiki/Installing-Neovim).

## Install ag command

Here, we use `ag`([the silver searcher](https://github.com/ggreer/the_silver_searcher)) as the search command of `CtrlP` command, So you need to install it accoradingly. If there is no any `ag` in your system, the default search mechanism of CtrlP is used.

For installation details, check [here](https://github.com/ggreer/the_silver_searcher#installing).


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


## Install [vim-plug](https://github.com/junegunn/vim-plug).

If you have `curl` installed, you can execute the following command to install `vim-plug`:

```
curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

Otherwise, you may check [this](https://github.com/junegunn/vim-plug#installation).

## Install all the plugings

- Open your nvim and execute `:PlugInstall`.
- Compile YCM according to [http://valloric.github.io/YouCompleteMe/#installation](http://valloric.github.io/YouCompleteMe/#installation).
- Update remote plugins by running `:UpdateRemotePlugins` in nvim.

## Install YCM with a specific version of python.

If you don't want to use the system's default python interpreter, or if you opt with many different versions of python, you can compile YCM with a specific version of python.

For the details, please check this [article](http://www.d0u9.xyz/compile-ycm-with-a-specific-verion-of-python-which-is-installed-via-pyenv).

```
CONFIGURE_OPTS="--enable-shared --with-system-expat " pyenv install 3.9.3
```


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
