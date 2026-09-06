# Cache the shell init that a tool prints for itself.
#
# `fzf --zsh`, `zoxide init zsh` and `dircolors -b` cost about 22ms of forking
# per interactive shell between them, for output that changes only when the
# executable does. Their result is cached under $XDG_CACHE_HOME/zsh and sourced
# from there instead.
#
# Shared by core/aliases.zsh and core/integrations.zsh so that one
# implementation decides when a cache is stale.

# _dot_source_tool_init <cache name> <executable> <command...>
#
# Sources the cached output of <command...>, regenerating it first when the
# cache is missing or does not match the current executable. Returns non-zero
# when the tool could not produce anything, so a caller can fall back.
_dot_source_tool_init() {
    emulate -L zsh

    local name=$1 exe=$2
    shift 2

    local cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/zsh
    local cache=$cache_dir/$name.zsh
    local first out

    # Identify the executable by its resolved path, size and modification
    # time, not by comparing timestamps against the cache.
    #
    # A Homebrew install is a symlink into Cellar/<version>/, and test
    # operators follow it, so `-nt` compares the bottle's *build* time -- weeks
    # older than the cache in the normal case. A tool upgraded tomorrow would
    # look older than the cache it should invalidate and the stale init script
    # would be sourced against the new binary. The resolved path carries the
    # version, so it changes on every upgrade; size and mtime catch a binary
    # replaced in place.
    #
    # zstat is a builtin and forks nothing. Where it is unavailable the
    # fingerprint degrades to the resolved path alone, which still catches a
    # Homebrew or pkg upgrade.
    local -A st
    local target=${commands[$exe]:A}
    zmodload -F zsh/stat b:zstat 2>/dev/null && zstat -H st -- "$target" 2>/dev/null

    # The command line is part of the key too, so changing a flag at the call
    # site invalidates the cache that was generated without it.
    local header="# generated from: $* | ${target}:${st[mtime]-}:${st[size]-}"

    if [[ -s $cache ]]; then
        IFS= read -r first < $cache
        if [[ $first == $header ]]; then
            source "$cache"
            return 0
        fi
    fi

    out=$("$@" 2>/dev/null) || return 1
    [[ -n $out ]] || return 1

    # Write through a temporary file so an interrupted or full-disk write
    # cannot leave a truncated init script that every later shell sources.
    [[ -d $cache_dir ]] || mkdir -p "$cache_dir"
    if print -rl -- "$header" "$out" > "$cache.tmp$$" 2>/dev/null &&
       mv -f "$cache.tmp$$" "$cache" 2>/dev/null; then
        source "$cache"
    else
        rm -f "$cache.tmp$$"
        eval "$out"
    fi
}
