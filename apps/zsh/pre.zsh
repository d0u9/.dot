# Reserved for integrations that must load before core and prompt
# initialization.

source "$DOT_ZSH_DIR/lib/host-hooks.zsh"
_dot_source_host_hooks pre
unfunction _dot_source_host_hooks

if [[ ${DOT_ZSH_TRACE_HOOKS:-0} == 1 ]]; then
    warn "Loading Zsh config"
fi
