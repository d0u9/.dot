CURRENT_BG='NONE'
SEGMENT_SEPARATOR_L='‹'
SEGMENT_SEPARATOR_R='›'

custom_git() {
    ZSH_THEME_GIT_PROMPT_PREFIX=" $(echo '\uf126'):(%{%F{red}%}"
    ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
    ZSH_THEME_GIT_PROMPT_DIRTY="%{%F{blue}%})%{%F{yellow}%} ●%{$reset_color%} "
    ZSH_THEME_GIT_PROMPT_CLEAN="%{%F{blue}%})"

    ZSH_THEME_HG_PROMPT_PREFIX="$ZSH_THEME_GIT_PROMPT_PREFIX"
    ZSH_THEME_HG_PROMPT_SUFFIX="$ZSH_THEME_GIT_PROMPT_SUFFIX"
    ZSH_THEME_HG_PROMPT_DIRTY="$ZSH_THEME_GIT_PROMPT_DIRTY"
    ZSH_THEME_HG_PROMPT_CLEAN="$ZSH_THEME_GIT_PROMPT_CLEAN"

    ZSH_THEME_RUBY_PROMPT_PREFIX="%{%F{red}%}‹"
    ZSH_THEME_RUBY_PROMPT_SUFFIX="› %{$reset_color%}"

    ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX="%{$F{green}%}‹"
    ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX="› %{$reset_color%}"
    ZSH_THEME_VIRTUALENV_PREFIX="$ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX"
    ZSH_THEME_VIRTUALENV_SUFFIX="$ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX"

}

# $1: how long
# $2: symbol
function space() {
    local n=$1
    local c=$2
    [[ -n "$c" ]] || c=" "
    echo -n "${(pl:n::$c:)}"
}

function segment() {
    [[ -n $3 ]] && echo -n "$SEGMENT_SEPARATOR_L$3%f%b%k$SEGMENT_SEPARATOR_R"
}

function segment_nowrap() {
    [[ -n $3 ]] && echo -n "$3%f%b%k"
}

prompt_return_status() {
    local -a symbols

    if [[ $RETVAL -ne 0 ]]; then
        symbols+="%{%F{red}%}%B󱞾 ✘"
    else
        symbols+="%{%F{green}%}%B󱞾 ✔"
    fi

    if [[ -n "$symbols" ]]; then
        space 2 "═"
        segment default default "$symbols"
    fi
}

prompt_datetime() {
    local -a symbols

    symbols+="%{%F{yellow}%}%B"
    symbols+="%D{%Y%m%d %H:%M:%S}"

    space 2 "═"
    segment default default "$symbols"
}

prompt_current_dir() {
    local -a symbols
    symbols+="%{%F{blue}%}%B%~"
    if [[ -n "$symbols" ]]; then
        space 2 "═"
        segment default default "$symbols"
    fi
}

prompt_git() {
    local -a symbols
    local git_info="$(git_prompt_info)"
    [[ -n "$git_info" ]] && symbols+="$git_info"
    local hg_info="$(hg_prompt_info)"
    [[ -n "$hg_info" ]] && symbols+="$hg_info"

    if [[ -n "$symbols" ]]; then
        space 2 "═"
        segment default default "$symbols"
    fi
}

# Virtualenv: current working virtualenv
prompt_virtualenv() {
    if [[ -n "$VIRTUAL_ENV" && -n "$VIRTUAL_ENV_DISABLE_PROMPT" ]]; then
        space 2 "═"
        segment default default "(${VIRTUAL_ENV:t:gs/%/%%})"
    fi
}

prompt_rvm_ruby() {
    ZSH_THEME_RVM_PROMPT_OPTIONS="i v g"

    local -a symbols
    local rvm_ruby_info=$(ruby_prompt_info)
    [[ -n "$rvm_ruby_info" ]] && symbols+="$rvm_ruby_info"

    if [[ -n "$symbols" ]]; then
        space 2 "═"
        segment default default "$symbols"
    fi
}

prompt_userhost() {
    local -a symbols
    symbols+="%B%(!.%{%F{red}%}.%{%F{cyan}%})%n@%m"
    if [[ -n "$symbols" ]]; then
        # space 3 '='
        segment_nowrap default default "$symbols"
    fi
}

prompt_user_symbol() {
    local -a symbols
    symbols+="%B%(!.#.$)"
    [[ -n "$symbols" ]] && segment_nowrap default default "$symbols"
}

## Main prompt
custom_git
build_prompt() {
    RETVAL=$?
    prompt_return_status
    prompt_virtualenv
    prompt_rvm_ruby
    prompt_datetime
    prompt_git
    prompt_current_dir
    space 2 "═"
}

build_second_prompt() {
    prompt_userhost
    space 1
    prompt_user_symbol
}

#  ─╮
PROMPT='%{%f%b%k%}╭─ $(build_prompt)
╰─  $(build_second_prompt) '
