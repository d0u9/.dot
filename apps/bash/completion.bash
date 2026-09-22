# Load the first bash-completion installation found: Homebrew's, then the
# Linux system package locations. The Homebrew prefix comes from
# $DOT_BREW_PREFIX, which apps/shell/lib.sh resolves for both shells, so the
# platform and architecture prefixes are not spelled out again here.
# Individual command completions are loaded on demand by bash-completion.
for _dot_bash_completion in \
    "${DOT_BREW_PREFIX:+$DOT_BREW_PREFIX/etc/profile.d/bash_completion.sh}" \
    /usr/share/bash-completion/bash_completion \
    /etc/bash_completion
do
    [ -n "$_dot_bash_completion" ] || continue
    if [ -r "$_dot_bash_completion" ]; then
        source "$_dot_bash_completion"
        break
    fi
done
unset _dot_bash_completion

# Brew provides this completion even without the bash-completion package.
# $DOT_BREW_PREFIX replaces a `brew --prefix` fork, which costs as much as
# starting brew itself.
if [ -n "${DOT_BREW_PREFIX:-}" ] && ! complete -p brew >/dev/null 2>&1 &&
   [ -r "$DOT_BREW_PREFIX/etc/bash_completion.d/brew" ]; then
    source "$DOT_BREW_PREFIX/etc/bash_completion.d/brew"
fi

# Readline completion remains useful even when the optional package is absent.
# Unsupported variables are ignored for compatibility with older server Bash
# and Readline versions.
bind 'set completion-ignore-case on' 2>/dev/null
bind 'set completion-map-case on' 2>/dev/null
bind 'set show-all-if-ambiguous on' 2>/dev/null
bind 'set menu-complete-display-prefix on' 2>/dev/null
bind 'set colored-stats on' 2>/dev/null
bind 'set visible-stats on' 2>/dev/null

# A partially typed command makes Up/Down search only matching history.
bind '"\e[A": history-search-backward' 2>/dev/null
bind '"\e[B": history-search-forward' 2>/dev/null
bind '"\e[Z": menu-complete-backward' 2>/dev/null
