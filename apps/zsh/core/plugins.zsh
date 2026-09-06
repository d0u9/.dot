# Load the configured ZLE plugins directly after all other interactive
# integrations.

DOT_ZSH_PLUGIN_DIR=${DOT_ZSH_PLUGIN_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins}

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
