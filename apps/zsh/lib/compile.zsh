# Byte-compilation targets and the routine that maintains them.
#
# Three callers share this file so that the list of what gets compiled exists
# in one place: core/plugins.zsh compiles what is out of date at startup,
# bin/zsh-compile does it on demand from the command line, and the installer
# runs that command after updating the plugin checkouts.
#
# Sourcing this file only defines functions.

# Fill $reply with every file this configuration byte-compiles.
#
# `zshrc` is deliberately absent: Zsh opens it as ~/.zshrc, so it would look
# for ~/.zshrc.zwc next to the symlink rather than next to the source, outside
# this repository. Powerlevel10k is absent because it compiles itself on first
# load. zsh-syntax-highlighting's 288 files of highlighter test data are absent
# because no shell reads them.
dot_zsh_compile_targets() {
    emulate -L zsh

    local plugins=${DOT_ZSH_PLUGIN_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins}
    # Every caller sets DOT_ZSH_DIR: zshrc derives it from its own location and
    # bin/zsh-compile from the script's. There is deliberately no ~/.dot
    # fallback -- guessing a checkout location would silently compile the wrong
    # tree on a host that keeps it elsewhere.
    local conf=$DOT_ZSH_DIR

    reply=(
        # ZLE plugins: the entry points and the highlighters they load.
        $plugins/zsh-autosuggestions/*.zsh(.N)
        $plugins/zsh-syntax-highlighting/*.zsh(.N)
        $plugins/zsh-syntax-highlighting/highlighters/*/*.zsh(.N)

        # This configuration's own sourced files.
        $conf/lib.sh(.N)
        $conf/*.zsh(.N)
        $conf/core/*.zsh(.N)
        $conf/lib/*.zsh(.N)
    )
}

# dot_zsh_compile [-f]
#
# Compile every target whose .zwc is missing or older than its source; with
# -f, recompile all of them. A target in a directory that cannot be written --
# a checkout owned by root, a read-only mount -- is left alone rather than
# retried and reported as a failure on every shell.
#
# Results go into three arrays rather than to the terminal, so that the
# startup path stays silent and only bin/zsh-compile prints:
#   _dot_zsh_compiled  _dot_zsh_skipped  _dot_zsh_failed
#
# Zsh ignores a .zwc older than its source, so a target that is skipped or
# fails is slower to load, never stale.
dot_zsh_compile() {
    emulate -L zsh

    local force=0
    [[ $1 == -f ]] && force=1

    local f
    local -a reply
    typeset -ga _dot_zsh_compiled=() _dot_zsh_skipped=() _dot_zsh_failed=()

    dot_zsh_compile_targets

    for f in $reply; do
        if (( ! force )) && [[ -f $f.zwc && $f.zwc -nt $f ]]; then
            continue
        fi
        if [[ ! -w ${f:h} ]]; then
            _dot_zsh_skipped+=($f)
            continue
        fi
        # -R marks the file to be read into memory in full, which is what
        # sourcing does anyway.
        if zcompile -R -- $f.zwc $f 2>/dev/null; then
            _dot_zsh_compiled+=($f)
        else
            _dot_zsh_failed+=($f)
        fi
    done

    (( ${#_dot_zsh_failed} == 0 ))
}

# dot_zsh_compile_clean
#
# Remove every target's compiled form. The next shell regenerates them.
dot_zsh_compile_clean() {
    emulate -L zsh

    local f
    local -a reply
    typeset -ga _dot_zsh_removed=()

    dot_zsh_compile_targets

    for f in $reply; do
        if [[ -f $f.zwc ]] && rm -f -- $f.zwc 2>/dev/null; then
            _dot_zsh_removed+=($f.zwc)
        fi
    done
}
