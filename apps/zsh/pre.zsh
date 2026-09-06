# Reserved for integrations that must load before core and prompt
# initialization.

_dot_host_pre="$DOT_ZSH_DIR/host-conf/00-zshrc-pre.sh"
[[ ! -r $_dot_host_pre ]] || source "$_dot_host_pre"
unset _dot_host_pre

if [[ ${DOT_ZSH_TRACE_HOOKS:-0} == 1 ]]; then
    warn "Loading Zsh config"
fi
