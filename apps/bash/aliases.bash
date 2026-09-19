alias l='ls -1'
alias ll='ls -lh'
alias la='ls -lah'
alias ..='cd ..'
alias ...='cd ../..'

if command -v eza >/dev/null 2>&1; then
    alias ls='eza --color=auto --group-directories-first'
    alias l='eza --color=auto --group-directories-first -1'
    alias ll='eza --color=auto --group-directories-first -l'
    alias la='eza --color=auto --group-directories-first -la'
    alias tree='eza --tree'
elif [ "$(uname -s)" = Darwin ]; then
    if command -v gls >/dev/null 2>&1; then
        alias ls='gls --color=auto'
    else
        alias ls='ls -G'
    fi
elif command -v ls >/dev/null 2>&1; then
    alias ls='ls --color=auto'
fi
if command -v nvim >/dev/null 2>&1; then
    alias vim='nvim'
    alias vi='nvim'
fi
