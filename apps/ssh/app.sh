desc="Removable OpenSSH client defaults"
default_on=0
link_replace=0
link=("config:$HOME/.ssh/config.d/00-dot.conf")

post() {
    local config="$HOME/.ssh/config"
    if [ ! -e "$config" ] && [ ! -L "$config" ]; then
        (umask 077; set -o noclobber; printf '%s\n' 'Include ~/.ssh/config.d/00-dot.conf' > "$config")
    fi
    info 'For dot settings to take priority, put this first in ~/.ssh/config:'
    printf '%s\n' 'Include ~/.ssh/config.d/00-dot.conf'
}
