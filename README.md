# .dot
The bucket of dot files.

# Description

This repo includes configuration files come from various most common used softewares, such as neovim, oh-my-zsh, tmux or chunks of my private applications. Each application's specific configuration files are contained in one directory which named as the application's name.

---

# Content
- [NeoVim](#neovim)
- [oh-my-zsh](#oh-my-zsh)
- [tmux](#tmux)

# Prerequisite

To obtain the full features of this configuration, you have to install NERD fonts which are patched lots of icons.

You can find more details of NERD fonts here: [https://github.com/ryanoasis/nerd-fonts](https://github.com/ryanoasis/nerd-fonts)

---

# NeoVim

> If you are a man occasionally understands Chinese, you may check this [article](http://www.d0u9.xyz/neovim-pei-zhi-yu-cha-jian-shuo-ming/) which is posted on my blog for more details.

## Install NeoVim

You may check [here](https://github.com/neovim/neovim/wiki/Installing-Neovim).

## Install ag command

Here, we use `ag` as the search command of `CtrlP` command. So you need to install it accoradingly. If there is no any `ag` in your system, the default search mechanism of CtrlP is used.

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

## Note about ycm confugration in Linux

Due to the fact that YCM's default configuration file is set up for OSX, you should change this file(`.dot/nvim/ycm_extra_config.py`) for Linux accoradingly. For more details about this configuration, you need to check the official document of YCM.

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
