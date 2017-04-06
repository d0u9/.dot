PRIVATE_CONF=$HOME/.dot/conf/oh-my-zsh

## For different platform
if [[ "$OSTYPE" = darwin* ]]; then
    source $HOME/.dot/oh-my-zsh/macos.sh
else
    source $HOME/.dot/oh-my-zsh/linux.sh
fi

## For private configurations
if [ -d "$PRIVATE_CONF" ]; then
    source $PRIVATE_CONF/private-zshrc.sh
fi
unset PRIVATE_CONF

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

if hash pyenv 2> /dev/null; then
    plugins+=(pyenv)
fi

if hash docker 2> /dev/null; then
    plugins+=(docker)
fi

## For alias
alias tmux="tmux -2"

## For environment variables
export TERM=xterm-256color

############
############

