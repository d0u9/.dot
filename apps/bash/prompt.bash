# A deliberately compact server prompt: the host is visually prominent and
# the plain single-line layout stays distinct from the workstation's
# Powerlevel10k prompt. \[...\] tells Readline that colour escapes take no
# screen columns.
if [ -t 1 ] && [ "${TERM:-dumb}" != dumb ]; then
    _dot_reset='\[\033[0m\]'
    _dot_dim='\[\033[2m\]'
    _dot_user='\[\033[1;36m\]'
    _dot_host='\[\033[1;33m\]'
    _dot_path='\[\033[1;34m\]'
    _dot_ok='\[\033[1;32m\]'
    _dot_bad='\[\033[1;31m\]'
else
    _dot_reset= _dot_dim= _dot_user= _dot_host= _dot_path=
    _dot_ok= _dot_bad=
fi

_dot_prompt_command() {
    local status=$?
    local mark colour
    if [ "$status" -eq 0 ]; then
        mark='$'
        colour=$_dot_ok
    else
        mark="!$status"
        colour=$_dot_bad
    fi
    if [ "$EUID" -eq 0 ]; then
        if [ "$status" -eq 0 ]; then
            mark='#'
        else
            mark="#!$status"
        fi
        colour=$_dot_bad
    fi
    PS1="${_dot_dim}[${_dot_reset}${_dot_user}\u${_dot_reset}@${_dot_host}\h${_dot_reset}${_dot_dim}]${_dot_reset} ${_dot_path}\w${_dot_reset} ${colour}${mark}${_dot_reset} "
}

# Preserve an existing PROMPT_COMMAND (for example one installed by a terminal
# integration). Ours runs first so $? is still the command's exit status.
# Bash 3 has no PROMPT_COMMAND array support.
case ${PROMPT_COMMAND:-} in
    '') PROMPT_COMMAND=_dot_prompt_command ;;
    *_dot_prompt_command*) ;;
    *) PROMPT_COMMAND="_dot_prompt_command; ${PROMPT_COMMAND#;}" ;;
esac
