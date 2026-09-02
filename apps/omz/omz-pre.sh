info "[PRE] Loading OMZ config" $(cur_path_relative "$HOME/.dot" "$0")

##################         For Different Platforms           ##################
if [[ "$OSTYPE" = darwin* ]]; then
    source $DOT_OMZ_DIR/macos/macos-pre.sh
else
    source $DOT_OMZ_DIR/linux/linux-pre.sh
fi

## For plugins
command_exist fasd && plugins+=(fasd)
command_exist jump && eval "$(jump shell zsh --bind=z)"

if command_exist tmux; then
    plugins+=(tmuxinator)
    alias tmux="tmux -2"
fi

if command_exist nvim; then
    alias vi=nvim
    alias vim=nvim
fi

test -f $HOME/.cargo/env && source $HOME/.cargo/env
if command_exist cargo; then
    plugins+=(rust)
fi

ZSH_AUTOSUGGESTIONS_DIR=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
if [ -d "$ZSH_AUTOSUGGESTIONS_DIR" ]; then
    plugins+=(zsh-autosuggestions)
    bindkey '^\' autosuggest-accept
fi

# Pyenv
if command_exist pyenv; then
    # Instead of using `plugins+=(pyenv)`, we speed up the plugin process
    # by using the command below
    # eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    # eval "$(pyenv virtualenv-init -)"
fi

# nvm
# Look for both layouts: the git install under $NVM_DIR and the homebrew
# formula under $(brew --prefix)/opt/nvm, which differs per architecture.
export NVM_DIR="$HOME/.nvm"
for _nvm_prefix in "$NVM_DIR" "$HOMEBREW_PREFIX/opt/nvm"; do
    if [ -s "$_nvm_prefix/nvm.sh" ]; then
        source "$_nvm_prefix/nvm.sh"
        [ -s "$_nvm_prefix/etc/bash_completion.d/nvm" ] && \
            source "$_nvm_prefix/etc/bash_completion.d/nvm"
        break
    fi
done
unset _nvm_prefix

# Rbenv
command_exist rbenv && eval "$(rbenv init - zsh)"

# Docker
command_exist docker && plugins+=(docker)

# For zsh-syntax-highlighting
# Ref: https://github.com/zsh-users/zsh-syntax-highlighting
plugins+=(zsh-syntax-highlighting)

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
