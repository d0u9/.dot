# mise runs through its shims instead of `mise activate`, as in Zsh.
_dot_mise_shims=${MISE_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/mise}/shims
[ -d "$_dot_mise_shims" ] && PATH="$_dot_mise_shims:$PATH"
unset _dot_mise_shims
# Rust belongs to rustup, as in Zsh.
case ,${MISE_DISABLE_TOOLS:-}, in
    *,rust,*) ;;
    *) MISE_DISABLE_TOOLS=${MISE_DISABLE_TOOLS:+$MISE_DISABLE_TOOLS,}rust ;;
esac
export MISE_DISABLE_TOOLS
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash --cmd z)"
fi
if command -v fzf >/dev/null 2>&1; then
    _dot_fzf_init=$(fzf --bash 2>/dev/null) && eval "$_dot_fzf_init"
    unset _dot_fzf_init
fi
