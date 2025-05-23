info "[PRE] Loading OMZ config for Macos" $(cur_path_relative "$HOME/.dot" "$0")

# This config file specific to OS X platform.
# You can set any variables ONLY to OS X platform.

## For plugins
plugins+=(macos brew)

## Homebrew
export PATH="/opt/homebrew/bin:$PATH"

if [ -f /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
elif [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi


info "[PRE] Loading OMZ config for Macos - DONE " $(cur_path_relative "$HOME/.dot" "$0")
