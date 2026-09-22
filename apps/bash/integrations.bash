# mise activation captures current PATH and installs directory hooks, so
# generate it for every shell. Check resolved path: Bash can retain a stale
# hash after an uninstall, matching Zsh's executable-path guard.
if _dot_mise_path=$(type -P mise 2>/dev/null) && [ -x "$_dot_mise_path" ]; then
    eval "$("$_dot_mise_path" activate bash)"
fi
unset _dot_mise_path
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash --cmd z)"
fi
if command -v fzf >/dev/null 2>&1; then
    _dot_fzf_init=$(fzf --bash 2>/dev/null) && eval "$_dot_fzf_init"
    unset _dot_fzf_init
fi
