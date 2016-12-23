#! /bin/bash

DOT_DIR=$(dirname "$(pwd)/$0")

yes_or_no()
{
    while true; do
        read -p "$1 ([y]/n)?" -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            return 0
        elif [[ $REPLY =~ ^[Nn]$ ]]; then
            return 1
        else
            echo "Please entry Y, y or N, n"
        fi
    done
}

back_or_override()
{
    FILE=$1
    if [ -e $FILE ]; then
        yes_or_no "$FILE file exist, backup it"
        if [ $? -eq "0" ]; then
            if [ -e $FILE.bk ]; then
                yes_or_no "$FILE.bk exist, override it?"
                if [ $? -eq "1" ]; then
                    echo "Can't backup $FILE, abort!"
                    exit 1
                fi
                rm -fr $FILE.bk
            fi
            mv $FILE $FILE.bk
        else
            rm -fr $FILE
        fi
    fi
}

zsh()
{
    echo "installing zsh config files"

    ZSHRC_FILE=$DOT_DIR/oh-my-zsh/zshrc
    ZSHTHEME_FILE=$DOT_DIR/oh-my-zsh/oh-my-zsh_themes/d0u9.zsh-theme

    TGT_RC_FILE=$HOME/.zshrc
    TGT_THEME_FILE=$HOME/.oh-my-zsh/themes/d0u9.zsh-theme

    back_or_override $TGT_RC_FILE

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

    ln -s $ZSHRC_FILE $TGT_RC_FILE
    rm -fr $TGT_THEME_FILE
    ln -s $ZSHTHEME_FILE $TGT_THEME_FILE

    echo "install finished, you have to manually execute 'source ~/.zshrc' to active it"
    echo "nerd font is needed, you can find it on Github"
}

tmux()
{
    echo "installing zsh config files"

    TMUX_CONF=$DOT_DIR/tmux/tmux.conf
    TMUX_CONF_DIR=$DOT_DIR/tmux

    TGT_TMUX_CONF=$HOME/.tmux.conf
    TGT_TMUX_CONF_DIR=$HOME/.tmux

    back_or_override $TGT_TMUX_CONF
    ln -s $TMUX_CONF $TGT_TMUX_CONF

    back_or_override $TGT_TMUX_CONF_DIR
    ln -s $TMUX_CONF_DIR $TGT_TMUX_CONF_DIR

    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

    echo "install finished, you have to manuall execute 'prefix+I' in tmux to install plugins"

}

nvim()
{
    echo "installing nvim config files"
    NVIM_CONF=$DOT_DIR/nvim
    TGT_NVIM_CONF=$HOME/.config/nvim

    back_or_override $TGT_NVIM_CONF
    ln -s $NVIM_CONF $TGT_NVIM_CONF

    curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    echo "install finished, you have to execute ":plugInstall" in nvim to install plugins"
}

case "$1" in
    "zsh")
        zsh
    ;;
    "tmux")
        tmux
    ;;
    "nvim")
        nvim
    ;;
    *)
        echo "install all"
        zsh
        tmux
        nvim
    ;;
esac

