desc="Zsh shell, prompt and plugins, with fzf and zoxide"
release=(fzf zoxide)
# Keep this in step with DOT_ZSH_PLUGIN_DIR in zshrc.
plugin_dir=${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins
git=(
    "$plugin_dir/powerlevel10k https://github.com/romkatv/powerlevel10k.git"
    "$plugin_dir/zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions"
    "$plugin_dir/zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git"
)
link=("zshrc:$HOME/.zshrc")

# Compile the freshly cloned or updated plugins now, so the first interactive
# shell after an install does not pay for it. core/plugins.zsh performs the
# same check at startup, so skipping it costs speed once, never correctness.
post() {
    command_exist zsh || return 0
    DOT_ZSH_DIR=$APP_DIR DOT_ZSH_PLUGIN_DIR=$plugin_dir "$APP_DIR/bin/zsh-compile" > /dev/null ||
        warn "byte-compilation reported failures, continuing"
}
