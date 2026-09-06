info "[PRE] Loading zsh config" $(cur_path_relative "$HOME/.dot" "$0")

# Runs before core.zsh, so anything here can still influence completion: fpath
# additions and generated completion files have to be in place before compinit.

##################         For Different Platforms           ##################
if [[ "$OSTYPE" = darwin* ]]; then
    source $DOT_ZSH_DIR/macos/macos-pre.sh
else
    source $DOT_ZSH_DIR/linux/linux-pre.sh
fi

##################              Completions                  ##################
# Generate a completion script from a tool that ships one, and cache it. This
# replaces the oh-my-zsh plugins that existed only to run the same command --
# omz's rust, kubectl, docker and golang plugins were little else.
#
# Regenerated only when the binary is newer than the cache, so the usual cost
# is one stat. Running `tool completion zsh` on every startup instead would be
# a fork each, which is what made those plugins worth avoiding.
#
# $1: completion function name to write (without the leading underscore)
# $2...: command to run, its stdout becomes the completion script
dot_gen_completion() {
    local name="$1"; shift
    local bin
    bin=$(command -v "$1" 2>/dev/null) || return 0

    local out="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions/_$name"
    if [[ -s "$out" && "$out" -nt "$bin" ]]; then
        return 0
    fi

    debug "generating completion" "_$name"
    if ! "$@" > "$out.tmp" 2>/dev/null || [ ! -s "$out.tmp" ]; then
        rm -f "$out.tmp"
        warn "could not generate completion" "$name"
        return 1
    fi
    mv -f "$out.tmp" "$out"
}

##################                 Tools                     ##################

# Directory jumping. All three of these bind z, so pick one instead of
# letting whichever loads last silently win. zoxide first: it is a single
# static binary, which is the one that actually installs everywhere, and it
# is the only one still maintained.
if command_exist zoxide; then
    eval "$(zoxide init zsh)"
elif command_exist jump; then
    eval "$(jump shell zsh --bind=z)"
elif command_exist fasd; then
    eval "$(fasd --init auto)"
fi

if command_exist tmux; then
    alias tmux="tmux -2"
    # tmuxinator has no completion of its own; _tmuxinator is checked in under
    # completions/, taken from the oh-my-zsh plugin of the same name.
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
if command_exist rustup; then
    # Writes both _rustup and _cargo; the file is named for the former and
    # zsh picks the latter out of it by the #compdef tag inside.
    dot_gen_completion rustup rustup completions zsh
    dot_gen_completion cargo rustup completions zsh cargo
fi

command_exist kubectl && dot_gen_completion kubectl kubectl completion zsh
command_exist helm    && dot_gen_completion helm    helm completion zsh
command_exist docker  && dot_gen_completion docker  docker completion zsh
command_exist gh      && dot_gen_completion gh      gh completion -s zsh

# Pyenv
if command_exist pyenv; then
    # Instead of using oh-my-zsh's pyenv plugin, we speed up the process
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

##################     Load custom host specific config      ##################
### Load config file specifc to this host
### These specific configuration isn't included in git.
PRE_HOST_CONF=$DOT_ZSH_DIR/host-conf
if [ -d $PRE_HOST_CONF ]; then
    for f in $(find $PRE_HOST_CONF -name "*-pre.sh" | sort); do
        source "$f"
    done
fi

############
############

info "[PRE] Loading zsh config - DONE" $(cur_path_relative "$HOME/.dot" "$0")
