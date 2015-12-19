local ret_status="%(?:%{$fg_bold[white]%}%m %{$fg_bold[green]%}➜ :%{$fg_bold[white]%}%m %{$fg_bold[red]%}➜ %s)"
PROMPT='$(echo "\uf06c") ${ret_status}%{$fg_bold[green]%}%p %{$fg[cyan]%}%c %{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%} % %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

local warn="%(?: :$(echo '\uf12a')%(?..%? ))"
local date='$(date "+%Y-%m-%d %H:%M:%S")'
local symbol='$(echo "\uf017")'
RPROMPT="$warn $symbol $date"
