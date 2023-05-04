## For different platform
if [[ "$OSTYPE" = darwin* ]]; then
    source $HOME/.dot/oh-my-zsh/macos/macos-post.sh
else
    source $HOME/.dot/oh-my-zsh/linux/linux-post.sh
fi

### Load config file specifc to this host
### These specific configuration isn't included in git.
POST_HOST_CONF=$HOME/.dot/oh-my-zsh/host-conf/post-host.sh
if [ -f $POST_HOST_CONF ]; then
    source $POST_HOST_CONF
fi

