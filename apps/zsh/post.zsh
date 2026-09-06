source "$DOT_ZSH_DIR/core/prompt.zsh"

if [[ -o interactive ]]; then
    source "$DOT_ZSH_DIR/core/aliases.zsh"
    source "$DOT_ZSH_DIR/core/integrations.zsh"
    # Must stay last: syntax highlighting observes widgets created by all
    # integrations loaded before it.
    source "$DOT_ZSH_DIR/core/plugins.zsh"
fi

if [[ ${DOT_ZSH_TRACE_HOOKS:-0} == 1 ]]; then
    warn "Loading Zsh config - DONE"
fi
