# The two zle plugins that oh-my-zsh's `plugins` array used to load.
#
# Nothing about them needed omz -- they are ordinary scripts that get sourced,
# and omz was only providing the directory they happened to sit in. Order
# matters here and it is the reason this file is separate from the rest:
# zsh-syntax-highlighting wraps every zle widget defined before it, and
# zsh-autosuggestions expects to be loaded after that.

DOT_ZSH_PLUGIN_DIR=${DOT_ZSH_PLUGIN_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins}

# $1: plugin directory name, $2: file to source inside it
dot_load_plugin() {
    local dir="$DOT_ZSH_PLUGIN_DIR/$1"
    local file="$dir/$2"
    if [ -r "$file" ]; then
        source "$file"
    else
        warn "plugin not found, skipping" "$1"
    fi
}

# Must come before autosuggestions, and after anything else that defines a
# widget -- it rebinds what exists when it loads.
dot_load_plugin zsh-syntax-highlighting zsh-syntax-highlighting.zsh

dot_load_plugin zsh-autosuggestions zsh-autosuggestions.zsh
if (( $+functions[_zsh_autosuggest_start] )); then
    # Accept the whole suggestion. ^\ is otherwise unbound and sits next to
    # Return on this layout.
    bindkey '^\' autosuggest-accept
fi
