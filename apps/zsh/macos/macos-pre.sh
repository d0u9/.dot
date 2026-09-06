info "[PRE] Loading Zsh config for macOS" $(cur_path_relative "$HOME/.dot" "$0")

# This config file specific to OS X platform.
# You can set any variables ONLY to OS X platform.

## Homebrew
# /opt/homebrew is the Apple Silicon prefix and /usr/local the Intel one. A
# machine can carry both (an arm64 brew plus a Rosetta one), so probe the
# native prefix first and only then fall back.
for _prefix in /opt/homebrew /usr/local; do
    if [ -x "$_prefix/bin/brew" ]; then
        eval "$("$_prefix/bin/brew" shellenv)"
        break
    fi
done
unset _prefix

# Homebrew installed under some other prefix, but already on PATH.
if [ -z "$HOMEBREW_PREFIX" ] && command_exist brew; then
    eval "$(brew shellenv)"
fi


info "[PRE] Loading Zsh config for macOS - DONE " $(cur_path_relative "$HOME/.dot" "$0")
