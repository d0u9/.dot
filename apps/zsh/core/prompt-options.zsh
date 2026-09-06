# Never let Powerlevel10k download a platform binary during shell startup.
typeset -g GITSTATUS_AUTO_INSTALL=0

# Cache the probe because this file is sourced both before instant prompt and
# after p10k resets its POWERLEVEL9K_* options. Powerlevel10k's own installer
# resolves GITSTATUS_DAEMON, usrbin and per-platform cache paths and returns the
# version pattern expected for that candidate; `-n` makes the probe read-only.
if [[ -z ${_DOT_ZSH_GITSTATUS_COMPATIBLE+x} ]]; then
    typeset -ga _dot_gitstatus_info
    typeset _dot_gitstatus_install=$DOT_ZSH_PLUGIN_DIR/powerlevel10k/gitstatus/install
    typeset -g _DOT_ZSH_GITSTATUS_COMPATIBLE=false

    if [[ -r $_dot_gitstatus_install ]]; then
        _dot_gitstatus_info=("${(@f)$(
            sh "$_dot_gitstatus_install" -n -- printf '%s\n' 2>/dev/null
        )}")
        if (( ${#_dot_gitstatus_info} == 3 )) &&
           [[ -x ${_dot_gitstatus_info[1]} ]] &&
           "${_dot_gitstatus_info[1]}" -G "${_dot_gitstatus_info[2]}" \
               --version >/dev/null 2>&1; then
            _DOT_ZSH_GITSTATUS_COMPATIBLE=true
        fi
    fi

    unset _dot_gitstatus_info _dot_gitstatus_install
fi

if [[ $_DOT_ZSH_GITSTATUS_COMPATIBLE == true ]]; then
    typeset -g POWERLEVEL9K_DISABLE_GITSTATUS=false
else
    typeset -g POWERLEVEL9K_DISABLE_GITSTATUS=true
fi
