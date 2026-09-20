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
    _dot_git='\[\033[38;5;242m\]'
    _dot_dirty='\[\033[38;5;218m\]'
    _dot_arrows='\[\033[1;36m\]'
else
    _dot_reset= _dot_dim= _dot_user= _dot_host= _dot_path=
    _dot_ok= _dot_bad= _dot_git= _dot_dirty= _dot_arrows=
fi

_dot_git_prompt() {
    local branch changes counts ahead behind git_segment inside
    command -v git >/dev/null 2>&1 || return
    inside=$(git rev-parse --is-inside-work-tree 2>/dev/null) || return
    [ "$inside" = true ] || return

    branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) ||
        branch="@$(git rev-parse --short HEAD 2>/dev/null)"
    # Bash expands PS1 again when displaying it. Escape branch text so a
    # repository name cannot become prompt syntax or a command substitution.
    branch=${branch//\/\\}
    branch=${branch//\$/\\$}
    branch=${branch//\`/\\\`}
    git_segment="${_dot_git}${branch}"

    changes=$(git status --porcelain --untracked-files=normal 2>/dev/null)
    if [ -n "$changes" ]; then
        git_segment="${git_segment} ${_dot_dirty}*${_dot_git}"
    fi

    counts=$(git rev-list --left-right --count 'HEAD...@{upstream}' 2>/dev/null)
    if [ -n "$counts" ]; then
        read -r ahead behind <<< "$counts"
        if [ "$behind" -gt 0 ]; then
            git_segment="${git_segment} ${_dot_arrows}⇣${_dot_git}"
        fi
        if [ "$ahead" -gt 0 ]; then
            git_segment="${git_segment} ${_dot_arrows}⇡${_dot_git}"
        fi
    fi
    printf '%s' " ${_dot_dim}‹ ${git_segment}${_dot_dim} ›${_dot_reset}"
}

_dot_prompt_command() {
    local status=$?
    local mark colour git_segment
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
    git_segment=$(_dot_git_prompt)
    PS1="${_dot_dim}[${_dot_reset}${_dot_user}\u${_dot_reset}@${_dot_host}\h${_dot_reset}${_dot_dim}]${_dot_reset} ${_dot_path}\w${_dot_reset}${git_segment} ${colour}${mark}${_dot_reset} "
}

# Preserve an existing PROMPT_COMMAND (for example one installed by a terminal
# integration). Ours runs first so $? is still the command's exit status.
# Bash 3 has no PROMPT_COMMAND array support.
case ${PROMPT_COMMAND:-} in
    '') PROMPT_COMMAND=_dot_prompt_command ;;
    *_dot_prompt_command*) ;;
    *) PROMPT_COMMAND="_dot_prompt_command; ${PROMPT_COMMAND#;}" ;;
esac
