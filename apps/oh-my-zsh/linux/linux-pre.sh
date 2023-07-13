info "[PRE] Loading OMZ config for Linux" $(cur_path_relative "$HOME/.dot" "$0")
# This config file specific to Linux platform.
# You can set any variables ONLY to linux platform.

## Homebrew
if [ -d /home/linuxbrew/.linuxbrew ]; then
	plugins+=(brew)
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
info "[PRE] Loading OMZ config for Linux - DONE" $(cur_path_relative "$HOME/.dot" "$0")
