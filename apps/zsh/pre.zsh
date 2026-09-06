# Reserved for integrations that must load before core and prompt
# initialization.

if [[ ${DOT_ZSH_TRACE_HOOKS:-0} == 1 ]]; then
    warn "Loading Zsh config"
fi
