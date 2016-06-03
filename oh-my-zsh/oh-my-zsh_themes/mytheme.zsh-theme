if [[ $(whoami) == 'root' ]]; then
    local user_color="%{$fg_bold[red]%}%n%{$fg_bold[blue]%}$(echo '@')"
else
    local user_color="%{$fg_bold[green]%}%n%{$fg_bold[blue]%}$(echo '@')"
fi

local prompt="$user_color%{$fg_bold[white]%}%m"
local ret_status="%(?:${prompt} %{$fg_no_bold[green]%}$(echo '\uf07c'):${prompt} %{$fg_bold[red]%}$(echo '\uf07c')%s)"

if [[ $(whoami) == 'root' ]]; then
    PROMPT='${ret_status}%{$fg_bold[green]%}%p %{$fg[cyan]%}%c%{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%} %{$fg_no_bold[red]%}$(echo "\uf198") % %{$reset_color%}'
else
    PROMPT='${ret_status}%{$fg_bold[green]%}%p %{$fg[cyan]%}%c%{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%} %{$fg_no_bold[green]%}$(echo "\uf155") % %{$reset_color%}'
fi

ZSH_THEME_GIT_PROMPT_PREFIX=" $(echo '\uf126'):(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%})%{$fg[yellow]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

local warn="%(?: :$(echo '\uf12a')%(?..%? ))"
local date='$(date "+%Y-%m-%d %H:%M:%S")'
local symbol='$(echo "\uf017")'
RPROMPT="$warn $symbol $date"
