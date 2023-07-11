info "[POST] Loading OMZ config" $(cur_path_relative "$HOME/.dot" "$0")

## For different platform
if [[ "$OSTYPE" = darwin* ]]; then
    source $HOME/.dot/oh-my-zsh/macos/macos-post.sh
else
    source $HOME/.dot/oh-my-zsh/linux/linux-post.sh
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


### Load config file specifc to this host
### These specific configuration isn't included in git.
POST_HOST_CONF=$HOME/.dot/oh-my-zsh/host-conf
if [ -f $POST_HOST_CONF ]; then
    for f in $(find $POST_HOST_CONF -name "*-post.sh" | sort); do
        source "$f"
    done
fi

info "[POST] Loading OMZ config - DONE" $(cur_path_relative "$HOME/.dot" "$0")
