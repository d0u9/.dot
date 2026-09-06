source "$DOT_ZSH_DIR/core/prompt.zsh"

# No interactive test here: Zsh reads .zshrc only for interactive shells, and
# core/shell.zsh below the same entry point already relies on that. A guard on
# some of the files and not others only suggests a distinction that does not
# exist.
source "$DOT_ZSH_DIR/core/aliases.zsh"
source "$DOT_ZSH_DIR/core/integrations.zsh"
# Must stay last: syntax highlighting observes widgets created by all
# integrations loaded before it.
source "$DOT_ZSH_DIR/core/plugins.zsh"

if [[ ${DOT_ZSH_TRACE_HOOKS:-0} == 1 ]]; then
    warn "Loading Zsh config - DONE"
fi

_dot_host_post="$DOT_ZSH_DIR/host-conf/00-zshrc-post.sh"
[[ ! -r $_dot_host_post ]] || source "$_dot_host_post"
unset _dot_host_post
