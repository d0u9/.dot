# This config file specific to Linux platform.
# You can set any variables ONLY to linux platform.
plugins+=(brew)

## Homebrew
if [ -d /home/linuxbrew/.linuxbrew ]; then
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
