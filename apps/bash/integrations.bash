if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate bash)"
fi
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash --cmd z)"
fi
if command -v fzf >/dev/null 2>&1; then
    _dot_fzf_init=$(fzf --bash 2>/dev/null) && eval "$_dot_fzf_init"
    unset _dot_fzf_init
fi
