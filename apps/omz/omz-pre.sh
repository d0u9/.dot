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
for _prefix in "$NVM_DIR" "${HOMEBREW_PREFIX:-/usr/local}/opt/nvm" /opt/homebrew/opt/nvm; do
    [ -s "$_prefix/nvm.sh" ] && NVM_SH_DIR="$_prefix" && break
done
unset _prefix

# Sourcing nvm.sh costs well over a second, so defer it: each of the commands
# below is a stub that loads nvm for real on first use, then re-runs itself.
if [ -n "$NVM_SH_DIR" ]; then
    nvm_load() {
        unset -f nvm node npm npx nvm_load
        source "$NVM_SH_DIR/nvm.sh"
        # The git install ships completion as $NVM_DIR/bash_completion; the
        # homebrew formula puts it under etc/bash_completion.d/nvm.
        for _c in "$NVM_SH_DIR/bash_completion" \
                  "$NVM_SH_DIR/etc/bash_completion.d/nvm"; do
            [ -s "$_c" ] && source "$_c" && break
        done
        unset _c
    }

    for _cmd in nvm node npm npx; do
        eval "$_cmd() { nvm_load; $_cmd \"\$@\"; }"
    done
    unset _cmd
fi

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
