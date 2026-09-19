# Load the first bash-completion installation found. These cover Linux system
# packages and Homebrew on Apple Silicon and Intel Macs. Individual command
# completions are loaded on demand by bash-completion itself.
for _dot_bash_completion in \
    /opt/homebrew/etc/profile.d/bash_completion.sh \
    /usr/local/etc/profile.d/bash_completion.sh \
    /usr/share/bash-completion/bash_completion \
    /etc/bash_completion
do
    if [ -r "$_dot_bash_completion" ]; then
        source "$_dot_bash_completion"
        break
    fi
done
unset _dot_bash_completion

# Brew provides this completion even without the bash-completion package.
if command -v brew >/dev/null 2>&1 && ! complete -p brew >/dev/null 2>&1; then
    _dot_brew_prefix=$(brew --prefix 2>/dev/null)
    if [ -r "$_dot_brew_prefix/etc/bash_completion.d/brew" ]; then
        source "$_dot_brew_prefix/etc/bash_completion.d/brew"
    fi
    unset _dot_brew_prefix
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
