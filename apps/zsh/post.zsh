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
P10K_DIR=$DOT_ZSH_PLUGIN_DIR/powerlevel10k
if [ -d "$P10K_DIR" ]; then
    source $P10K_DIR/powerlevel10k.zsh-theme
    source $DOT_ZSH_DIR/p10k.zsh
else
    warn "powerlevel10k not found, skipping" "$P10K_DIR"
fi


### Load config file specifc to this host
### These specific configuration isn't included in git.
POST_HOST_CONF=$DOT_ZSH_DIR/host-conf
if [ -d $POST_HOST_CONF ]; then
    for f in $(find $POST_HOST_CONF -name "*-post.sh" | sort); do
        source "$f"
    done
fi

info "[POST] Loading zsh config - DONE " $(cur_path_relative "$HOME/.dot" "$0")
