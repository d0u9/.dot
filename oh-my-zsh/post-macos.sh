#This config file specific to OS X platform.
# You can set any variables ONLY to OS X platform.

## Alias

if hash gls 2> /dev/null; then
    alias ls='gls --color=tty'
fi
