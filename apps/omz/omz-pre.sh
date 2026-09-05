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
    # Also what zellij opens the scrollback with, and what git, crontab and
    # fc fall back to.
    export EDITOR=nvim
    export VISUAL=nvim
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

nvm_source() {
    source "$NVM_SH_DIR/nvm.sh"
    # The git install ships completion as $NVM_DIR/bash_completion; the
    # homebrew formula puts it under etc/bash_completion.d/nvm.
    for _c in "$NVM_SH_DIR/bash_completion" \
              "$NVM_SH_DIR/etc/bash_completion.d/nvm"; do
        [ -s "$_c" ] && source "$_c" && break
    done
    unset _c
}

if [ -n "$NVM_SH_DIR" ]; then
    # Sourcing nvm.sh costs well over a second. Resolve the default version by
    # hand instead: aliases chain on disk (default -> lts/* -> lts/<name> ->
    # vX.Y.Z), so follow them until a real version directory falls out.
    _ver=default
    _hops=0
    while [ -r "$NVM_DIR/alias/$_ver" ] && [ "$_hops" -lt 10 ]; do
        read -r _ver < "$NVM_DIR/alias/$_ver"
        _hops=$((_hops + 1))
    done

    if [ -d "$NVM_DIR/versions/node/$_ver/bin" ]; then
        # Put that version on PATH directly. This covers every globally
        # installed binary -- pnpm, corepack, and anything else npm dropped in
        # there -- not just node, npm and npx.
        export PATH="$NVM_DIR/versions/node/$_ver/bin:$PATH"

        # Only `nvm` itself is a shell function, so it is the one command that
        # still needs the script. Load it on first use.
        nvm() {
            unset -f nvm
            nvm_source
            nvm "$@"
        }
    else
        # Default version could not be resolved, so pay the cost and let nvm
        # work it out. Correctness over startup time.
        nvm_source
    fi
    unset _ver _hops
fi

# Rbenv
command_exist rbenv && eval "$(rbenv init - zsh)"

# Docker
command_exist docker && plugins+=(docker)

# The pure prompt sets the terminal title on a precmd hook of its own, which
# runs after oh-my-zsh's. With both enabled every prompt flashes "%n@%m:%~"
# before pure repaints it as the plain path, so leave the titles to pure.
DISABLE_AUTO_TITLE="true"

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
