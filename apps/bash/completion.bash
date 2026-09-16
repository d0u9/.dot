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
