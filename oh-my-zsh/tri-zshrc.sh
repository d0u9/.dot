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

## For plugins
if hash fasd 2> /dev/null; then
    plugins+=(fasd)
fi

if hash tmux 2> /dev/null; then
    plugins+=(tmuxinator)
fi

test -d $HOME/.pyenv/bin && export PATH="$PATH:$HOME/.pyenv/bin"
if hash pyenv 2> /dev/null; then
    # Instead of using `plugins+=(pyenv)`, we speed up the plugin process
    # by using the command below
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
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

