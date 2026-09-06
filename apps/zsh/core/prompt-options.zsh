# Never let Powerlevel10k download a platform binary during shell startup.
typeset -g GITSTATUS_AUTO_INSTALL=0

# Cache the probe because this file is sourced both before instant prompt and
# after p10k resets its POWERLEVEL9K_* options. Powerlevel10k's own installer
# resolves GITSTATUS_DAEMON, usrbin and per-platform cache paths and returns the
# version pattern expected for that candidate; `-n` makes the probe read-only.
#
# Running that probe costs a `sh` fork plus a `gitstatusd --version` fork, about
# 20ms of a ~170ms startup, and it happens before instant prompt -- the one
# stretch where a fork is most visible. So the answer is also cached on disk,
# keyed on the sizes and modification times of the installer script and of the
# daemon it resolved last time. Reading that key uses zstat, which is a builtin
# and forks nothing; a Powerlevel10k update or a replaced daemon changes it and
# forces a fresh probe.
if [[ -z ${_DOT_ZSH_GITSTATUS_COMPATIBLE+x} ]]; then
    () {
        emulate -L zsh

        local install=$DOT_ZSH_PLUGIN_DIR/powerlevel10k/gitstatus/install
        local cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/zsh
        local cache=$cache_dir/gitstatus-probe
        local -a probe cached
        local -A st
        local daemon

        typeset -g _DOT_ZSH_GITSTATUS_COMPATIBLE=false
        [[ -r $install ]] || return 0

        # Build "<mtime>:<size>" for each argument, or fail if any is missing.
        local -a fingerprint
        _dot_fingerprint() {
            local f
            fingerprint=()
            for f in "$@"; do
                # zstat takes at most one +element, so read the whole hash.
                zstat -H st -- "$f" 2>/dev/null || return 1
                fingerprint+=("${st[mtime]}:${st[size]}")
            done
        }

        if zmodload -F zsh/stat b:zstat 2>/dev/null &&
           [[ -r $cache ]]; then
            cached=("${(@f)"$(<$cache)"}")
            if (( ${#cached} == 3 )) &&
               _dot_fingerprint "$install" "${cached[1]}" &&
               [[ ${(j.,.)fingerprint} == ${cached[2]} ]]; then
                _DOT_ZSH_GITSTATUS_COMPATIBLE=${cached[3]}
                unfunction _dot_fingerprint
                return 0
            fi
        fi

        probe=("${(@f)$(
            sh "$install" -n -- printf '%s\n' 2>/dev/null
        )}")
        if (( ${#probe} == 3 )) &&
           [[ -x ${probe[1]} ]] &&
           "${probe[1]}" -G "${probe[2]}" --version >/dev/null 2>&1; then
            _DOT_ZSH_GITSTATUS_COMPATIBLE=true
        fi

        # Only worth caching once the daemon path is known and stattable; an
        # unusable probe is cheap to repeat and must not be remembered as an
        # answer for a daemon that may appear later.
        daemon=${probe[1]:-}
        if (( $+builtins[zstat] )) && [[ -n $daemon ]] &&
           _dot_fingerprint "$install" "$daemon"; then
            [[ -d $cache_dir ]] || mkdir -p "$cache_dir"
            print -rl -- "$daemon" "${(j.,.)fingerprint}" \
                "$_DOT_ZSH_GITSTATUS_COMPATIBLE" > "$cache" 2>/dev/null
        fi

        unfunction _dot_fingerprint
    }
fi

if [[ $_DOT_ZSH_GITSTATUS_COMPATIBLE == true ]]; then
    typeset -g POWERLEVEL9K_DISABLE_GITSTATUS=false
else
    typeset -g POWERLEVEL9K_DISABLE_GITSTATUS=true

    # An instant prompt cache written while gitstatus was in use carries a
    # _p9k_preinit function that starts the daemon this shell has just decided
    # not to use. That is a one-time problem with a stale file, so drop the
    # file rather than giving up instant prompt on every fallback host --
    # exactly the hosts where the slower vcs_info backend makes it worth most.
    # The next prompt writes a fresh cache for this backend.
    #
    # Powerlevel10k emits _p9k_preinit into the cache only when gitstatus is
    # enabled (see _p9k_init_vcs), so a cache this backend wrote does not match
    # and survives. `$(<file)` is read by the shell itself and forks nothing.
    () {
        local stale=${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh
        if [[ -r $stale && $(<$stale) == *_p9k_preinit* ]]; then
            rm -f -- "$stale" "$stale.zwc"
        fi
    }
fi
