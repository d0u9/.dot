info "[POST] Loading OMZ config " $(cur_path_relative "$HOME/.dot" "$0")

## For different platform
if [[ "$OSTYPE" = darwin* ]]; then
    source $DOT_OMZ_DIR/macos/macos-post.sh
else
    source $DOT_OMZ_DIR/linux/linux-post.sh
fi

## For zellij command alias
if command_exist zellij; then
    zr() {
        zellij run -- "$@"
    }

    ze() {
        zellij edit -- "$@"
    }

    zs() {
        dir="$1"
        if ! [ -d "$dir" ]; then
            error "'$dir' is not a valid dir"
            return 1
        fi
        zellij run --cwd "$dir" --close-on-exit -- $SHELL
    }

    zdump() {
        zellij action dump-screen "$@"
    }
fi

# For Pure theme setup
PURE_DIR=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/pure
if [ -d "$PURE_DIR" ]; then
    fpath+=($PURE_DIR)
    autoload -U promptinit; promptinit
    prompt pure
else
    warn "pure prompt not found, skipping" "$PURE_DIR"
fi

## OSC 133 prompt marking
# Reports where each prompt, command and command output begins and ends. That
# is what lets zellij's scroll mode jump between prompts ([ and ]), select the
# command at the scroll position (m) and copy the last command's output (c).
# These are advisory escape sequences: a terminal that does not implement them
# swallows them.
_dot_osc133_precmd() {
    local ret=$?
    # D carries the exit status of the command that just finished; there is no
    # such command before the first prompt.
    if [ -n "$_DOT_OSC133_STARTED" ]; then
        printf '\033]133;D;%s\007' "$ret"
    fi
    _DOT_OSC133_STARTED=1
    printf '\033]133;A\007'
}

_dot_osc133_preexec() {
    printf '\033]133;C\007'
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _dot_osc133_preexec
# Prepend rather than add-zsh-hook: this has to run before pure's own precmd so
# that the mark lands above pure's preprompt line, and so that $? is still the
# user's command rather than something a earlier hook ran.
if [[ ${precmd_functions[(ie)_dot_osc133_precmd]} -gt ${#precmd_functions} ]]; then
    precmd_functions=(_dot_osc133_precmd $precmd_functions)
fi

# B marks the end of the prompt, where typed input starts. It has to sit inside
# PROMPT rather than in a hook, and %{...%} keeps it zero-width. Appended after
# `prompt pure` above has already set PROMPT.
PROMPT="${PROMPT}%{$(printf '\033]133;B\007')%}"


### Load config file specifc to this host
### These specific configuration isn't included in git.
POST_HOST_CONF=$DOT_OMZ_DIR/host-conf
if [ -d $POST_HOST_CONF ]; then
    for f in $(find $POST_HOST_CONF -name "*-post.sh" | sort); do
        source "$f"
    done
fi

info "[POST] Loading OMZ config - DONE " $(cur_path_relative "$HOME/.dot" "$0")
