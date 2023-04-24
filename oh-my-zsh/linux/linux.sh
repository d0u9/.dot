# This config file specific to Linux platform.
# You can set any variables ONLY to linux platform.

## Homebrew
if [ -d /home/linuxbrew/.linuxbrew ]; then
	plugins+=(brew)
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
