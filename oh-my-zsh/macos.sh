# This config file specific to OS X platform.
# You can set any variables ONLY to OS X platform.

## For plugins
plugins+=(osx brew)

## Homebrew
export PATH="/opt/homebrew/bin:$PATH"
eval "$(/opt/homebrew/bin/brew shellenv)"

