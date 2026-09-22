# Initialize Homebrew before compinit and before selecting optional tools:
# `brew shellenv` prepends to $fpath, which compinit reads.
#
# $DOT_BREW_PREFIX is resolved in apps/shell/lib.sh, which both shells source,
# so the platform and architecture test lives there rather than once per shell.
# It is empty on a host without Homebrew.
#
# shellenv's output is cached. It does not depend on the incoming environment,
# contrary to what this file claimed before: every environment-sensitive part
# is a deferred expansion -- `${PATH+:$PATH}`, `${INFOPATH:-}`, and the MANPATH
# guard -- which the cached text expands when it is sourced, so the generated
# bytes are identical under any PATH or MANPATH. Verified by diffing the output
# under `env -i` against one where PATH already contained the prefix. The fork
# this removes cost 56ms, the largest single item in startup.
#
# The cache is keyed on the brew executable's resolved path, size and
# modification time, so a Homebrew upgrade regenerates it.
if [[ -n ${DOT_BREW_PREFIX:-} ]]; then
    source "$DOT_ZSH_DIR/lib/toolcache.zsh"
    # An absolute path: this runs before the prefix is on $PATH.
    _dot_source_tool_init brew-shellenv "$DOT_BREW_PREFIX/bin/brew" \
        "$DOT_BREW_PREFIX/bin/brew" shellenv zsh
    unfunction _dot_source_tool_init
fi
