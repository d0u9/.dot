# Load the configured ZLE plugins directly after all other interactive
# integrations.

DOT_ZSH_PLUGIN_DIR=${DOT_ZSH_PLUGIN_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins}

# Byte-compile what this file is about to source. Parsing the two plugins from
# source costs about 20ms per interactive shell; from .zwc files it is about
# 6ms, and this configuration's own files save another ~1.5ms.
#
# The compiled files are host-local build output, live beside their sources
# outside this repository for plugins, and are produced here rather than only
# by the installer so that a plugin updated by any means -- a `git pull` in the
# checkout, a fresh machine, a checkout restored from a backup -- is recompiled
# by the next shell without a separate step. `zsh-compile` does the same work
# explicitly; the target list lives in lib/compile.zsh so the two cannot drift.
#
# Zsh ignores a .zwc older than its source, so a missed recompilation is slow,
# never stale. The scan therefore only has to be good enough for the common
# case, and costs about 2ms of the 15ms it saves.
() {
    source "$DOT_ZSH_DIR/lib/compile.zsh"
    dot_zsh_compile
    unfunction dot_zsh_compile dot_zsh_compile_targets dot_zsh_compile_clean
    unset _dot_zsh_compiled _dot_zsh_skipped _dot_zsh_failed
}

dot_load_plugin() {
    local file="$DOT_ZSH_PLUGIN_DIR/$1/$2"
    if [ -r "$file" ]; then
        source "$file"
    else
        print -u2 -- "Zsh plugin not found: $1"
    fi
}

dot_load_plugin zsh-autosuggestions zsh-autosuggestions.zsh

# Keep this last. It observes the final set of ZLE widgets when loaded.
dot_load_plugin zsh-syntax-highlighting zsh-syntax-highlighting.zsh

unfunction dot_load_plugin
