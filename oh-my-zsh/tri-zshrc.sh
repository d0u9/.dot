TRI='TRI'

# For pyenv
PYENV_PATH=$HOME/.pyenv/bin
if [ -d "$PYENV_PATH" ]; then
    export PATH="$PYENV_PATH:$PATH"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi
unset PYENV_PATH

## For different platform
# if zephyr project exists

if [[ "$OSTYPE" = darwin* ]]; then
    source $PERSONAL_ZSHRC_PATH/macos.sh
else
    source $PERSONAL_ZSHRC_PATH/linux.sh
fi

## For plugins
if hash fasd 2> /dev/null; then
    plugins+=(fasd)
fi

if hash tmux 2> /dev/null; then
    plugins+=(tmuxinator)
fi

############
############

