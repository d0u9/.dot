PRIVATE_CONF=$HOME/.dot/conf/oh-my-zsh

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
if [[ "$OSTYPE" = darwin* ]]; then
    source macos.sh
else
    source linux.sh
fi

## For private configurations
if [ -d "$PRIVATE_CONF" ]; then
    source $PRIVATE_CONF/private-zshrc.sh
fi
unset PRIVATE_CONF

############
############

