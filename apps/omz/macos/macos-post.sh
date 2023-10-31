info "[POST] Loading OMZ config for Macos" $(cur_path_relative "$HOME/.dot" "$0")
# This config file specific to OS X platform.
# You can set any variables ONLY to OS X platform.

## Alias

if hash gls 2> /dev/null; then
    alias ls='gls --color=tty'
fi

if [ -d "$HOME/.docker" ]; then
    export PATH="$PATH:$HOME/.docker/bin"
fi

### Make neomutt happy
stty discard undef

info "[POST] Loading OMZ config for Macos - DONE" $(cur_path_relative "$HOME/.dot" "$0")
