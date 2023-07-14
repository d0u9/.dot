info "[PRE] Loading OMZ config" $(cur_path_relative "$HOME/.dot" "$0")

##################         For Different Platforms           ##################
if [[ "$OSTYPE" = darwin* ]]; then
    source $DOT_OMZ_DIR/macos/macos-pre.sh
else
    source $DOT_OMZ_DIR/linux/linux-pre.sh
fi

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

if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    plugins+=(zsh-autosuggestions)
    bindkey '^o' autosuggest-accept
fi

# Pyenv
if hash pyenv 2> /dev/null; then
    # Instead of using `plugins+=(pyenv)`, we speed up the plugin process
    # by using the command below
    # eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    # eval "$(pyenv virtualenv-init -)"
fi

# Rbenv
if hash rbenv 2> /dev/null; then
    eval "$(rbenv init - zsh)"
fi

if hash docker 2> /dev/null; then
    plugins+=(docker)
fi

## For alias
alias tmux="tmux -2"

## For environment variables
export TERM=xterm-256color

##################     Load custom host specific config      ##################
### Load config file specifc to this host
### These specific configuration isn't included in git.
PRE_HOST_CONF=$DOT_OMZ_DIR/host-conf
if [ -d $PRE_HOST_CONF ]; then
    for f in $(find $PRE_HOST_CONF -name "*-pre.sh" | sort); do
        source "$f"
    done
fi

############
############

info "[PRE] Loading OMZ config - DONE" $(cur_path_relative "$HOME/.dot" "$0")
