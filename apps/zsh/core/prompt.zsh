P10K_DIR=$DOT_ZSH_PLUGIN_DIR/powerlevel10k
if [ -r "$P10K_DIR/powerlevel10k.zsh-theme" ]; then
    source "$P10K_DIR/powerlevel10k.zsh-theme"
    source "$DOT_ZSH_DIR/core/p10k.zsh"
else
    print -u2 -- "powerlevel10k not found: $P10K_DIR"
fi
unset P10K_DIR _DOT_ZSH_GITSTATUS_COMPATIBLE
