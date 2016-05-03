TRI='TRI'
TRI_CONF=$HOME/.dot/conf

# For pyenv
PYENV_PATH=$HOME/.pyenv/bin
if [ -d "$PYENV_PATH" ]; then
    export PATH="$PYENV_PATH:$PATH"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi
unset PYENV_PATH

## For plugins
if hash fasd 2> /dev/null; then
    plugins+=(fasd)
fi

if hash tmux 2> /dev/null; then
    plugins+=(tmuxinator)
fi

## For different platform
PERSONAL_ZSHRC_PATH=$TRI_CONF/oh-my-zsh
if [[ "$OSTYPE" = darwin* ]]; then
    source $PERSONAL_ZSHRC_PATH/macos.sh
else
    source $PERSONAL_ZSHRC_PATH/linux.sh
fi
unset PERSONAL_ZSHRC_PATH

############
############

