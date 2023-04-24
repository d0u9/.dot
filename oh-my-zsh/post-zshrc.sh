## For different platform
if [[ "$OSTYPE" = darwin* ]]; then
    source $HOME/.dot/oh-my-zsh/macos/post-macos.sh
else
    source $HOME/.dot/oh-my-zsh/linux/post-linux.sh
fi

