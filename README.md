# .dot
The bucket of dot files.


# Description

This repo includes configuration files come from various most common used softewares, such as neovim, oh-my-zsh, tmux or chunks of my private applications. Each application's specific configuration files are contained in one directory which named as the application's name.


# Content
- [Vim](#vim)
- [NeoVim](#neovim)

# Vim

- Install `vundle` according to [https://github.com/VundleVim/Vundle.vim#quick-start](https://github.com/VundleVim/Vundle.vim#quick-start)
- Make symbol link to `~/.vimrc`:

```
`ln -s .dot/vimrc ~/.vimrc`.
```

- Open your Vim and execute `:PluginInstall`.
- Compile YCM according to [http://valloric.github.io/YouCompleteMe/#installation](http://valloric.github.io/YouCompleteMe/#installation)
- Vim theme, Copy the theme to `~/.vim/colors/`.

# NeoVim

> If you are a man occasionally understand Chinese, you may check this [article](http://www.d0u9.xyz/neovim-pei-zhi-yu-cha-jian-shuo-ming/) which is posted on my blog for more details.

- Create `XDG_CONFIG_HOME`:

```
mkdir -p ${XDG_CONFIG_HOME:=$HOME/.config}
```

- Make a symbol link of nvim configuration:

```
ln -s .dot/nvim $XDG_CONFIG_HOME/
```

- Execute the following command to install [vim-plug](https://github.com/junegunn/vim-plug)

```
curl -fLo $XDG_CONFIG_HOME/nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

- Install python support for neovim:

```
pip install neovim
```

- Open your nvim and execute `:PlugInstall`
- Compile YCM according to [http://valloric.github.io/YouCompleteMe/#installation](http://valloric.github.io/YouCompleteMe/#installation)

# License
![CC License](http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png)
