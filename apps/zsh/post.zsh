info "[POST] Loading zsh config " $(cur_path_relative "$HOME/.dot" "$0")

## For different platform
if [[ "$OSTYPE" = darwin* ]]; then
    source $DOT_ZSH_DIR/macos/macos-post.sh
else
    source $DOT_ZSH_DIR/linux/linux-post.sh
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

## Prompt
# DOT_PROMPT picks which prompt to load; set it in host-conf to try one on a
# single machine. Anything not installed here falls back to pure, so the same
# config still comes up on a host that has not got it.
DOT_PROMPT="${DOT_PROMPT:-pure}"

if [ "$DOT_PROMPT" = "starship" ] && ! command_exist starship; then
    warn "starship not found, falling back to pure"
    DOT_PROMPT=pure
fi

case "$DOT_PROMPT" in
    starship)
        # starship reads no zsh state, so its config carries everything.
        export STARSHIP_CONFIG=$DOT_ZSH_DIR/starship.toml
        eval "$(starship init zsh)"
        ;;
    p10k)
        P10K_DIR=$DOT_ZSH_PLUGIN_DIR/powerlevel10k
        if [ -d "$P10K_DIR" ]; then
            source $P10K_DIR/powerlevel10k.zsh-theme
            source $DOT_ZSH_DIR/p10k.zsh
        else
            warn "powerlevel10k not found, skipping" "$P10K_DIR"
        fi
        ;;
    pure)
        PURE_DIR=$DOT_ZSH_PLUGIN_DIR/pure
        if [ -d "$PURE_DIR" ]; then
            fpath+=($PURE_DIR)
            autoload -U promptinit; promptinit
            prompt pure
        else
            warn "pure prompt not found, skipping" "$PURE_DIR"
        fi
        ;;
    *)
        error "unknown DOT_PROMPT, no prompt loaded" "$DOT_PROMPT"
        ;;
esac

## OSC 133 prompt marking
# Reports where each prompt, command and command output begins and ends. That
# is what lets zellij's scroll mode jump between prompts ([ and ]), select the
# command at the scroll position (m) and copy the last command's output (c).
# These are advisory escape sequences: a terminal that does not implement them
# swallows them.
#
# powerlevel10k emits these itself, and more thoroughly than this does -- it
# wraps the sequences for tmux and marks the right prompt as well -- so it is
# left to do the job when it is the prompt in use. pure and starship emit
# none, hence this block.
if [ "$DOT_PROMPT" != "p10k" ]; then

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
# Prepend rather than add-zsh-hook: this has to run before the prompt's own
# precmd so that the mark lands above its first line, and so that $? is still
# the user's command rather than something an earlier hook ran.
if [[ ${precmd_functions[(ie)_dot_osc133_precmd]} -gt ${#precmd_functions} ]]; then
    precmd_functions=(_dot_osc133_precmd $precmd_functions)
fi

# B marks the end of the prompt, where typed input starts. It has to sit inside
# PROMPT rather than in a hook, and %{...%} keeps it zero-width. Appended after
# the block above has set PROMPT -- starship sets it to a command substitution
# once at init rather than on every precmd, so appending to it still holds.
PROMPT="${PROMPT}%{$(printf '\033]133;B\007')%}"

fi  # DOT_PROMPT != p10k


### Load config file specifc to this host
### These specific configuration isn't included in git.
POST_HOST_CONF=$DOT_ZSH_DIR/host-conf
if [ -d $POST_HOST_CONF ]; then
    for f in $(find $POST_HOST_CONF -name "*-post.sh" | sort); do
        source "$f"
    done
fi

info "[POST] Loading zsh config - DONE " $(cur_path_relative "$HOME/.dot" "$0")
