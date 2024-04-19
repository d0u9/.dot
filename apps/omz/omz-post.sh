info "[POST] Loading OMZ config" $(cur_path_relative "$HOME/.dot" "$0")

## For different platform
if [[ "$OSTYPE" = darwin* ]]; then
    source $DOT_OMZ_DIR/macos/macos-post.sh
else
    source $DOT_OMZ_DIR/linux/linux-post.sh
fi

## For zellij command alias
if hash zellij 2> /dev/null; then
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
fpath+=($HOME/.oh-my-zsh/custom/plugins/pure)
autoload -U promptinit; promptinit
prompt pure


### Load config file specifc to this host
### These specific configuration isn't included in git.
POST_HOST_CONF=$DOT_OMZ_DIR/host-conf
if [ -d $POST_HOST_CONF ]; then
    for f in $(find $POST_HOST_CONF -name "*-post.sh" | sort); do
        source "$f"
    done
fi

info "[POST] Loading OMZ config - DONE" $(cur_path_relative "$HOME/.dot" "$0")
