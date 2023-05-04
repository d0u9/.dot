## For plugins
if hash fasd 2> /dev/null; then
    plugins+=(fasd)
fi

if hash tmux 2> /dev/null; then
    plugins+=(tmuxinator)
fi

test -f $HOME/.cargo/env && source $HOME/.cargo/env
if hash cargo 2> /dev/null; then
    plugins+=(rust)
fi

test -d $HOME/.pyenv/bin && export PATH="$PATH:$HOME/.pyenv/bin"
if hash pyenv 2> /dev/null; then
    # Instead of using `plugins+=(pyenv)`, we speed up the plugin process
    # by using the command below
    # eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    # eval "$(pyenv virtualenv-init -)"
fi

if hash docker 2> /dev/null; then
    plugins+=(docker)
fi

## For alias
alias tmux="tmux -2"

## For environment variables
export TERM=xterm-256color
##################         For Different Platforms           ##################
if [[ "$OSTYPE" = darwin* ]]; then
    source $HOME/.dot/oh-my-zsh/macos/macos-pre.sh
else
    source $HOME/.dot/oh-my-zsh/linux/linux-pre.sh
fi


##################     Load custom host specific config      ##################
### Load config file specifc to this host
### These specific configuration isn't included in git.
HOST_CONF=$HOME/.dot/oh-my-zsh/host-conf/host-pre.sh
if [ -f $HOST_CONF ]; then
    source $HOST_CONF
fi

############
############

