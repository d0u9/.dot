# This config file specific to OS X platform.
# You can set any variables ONLY to OS X platform.

## For plugins
plugins+=(osx)

if hash brew 2> /dev/null; then
    plugins+=(brew)
fi
