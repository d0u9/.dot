desc="Bash for servers: configuration and bash-completion"
link=("bashrc:$HOME/.bashrc" "bash_profile:$HOME/.bash_profile")

# Completion is optional so a minimal server still receives a usable shell.
post() {
    local file
    for file in /usr/share/bash-completion/bash_completion /etc/bash_completion \
        ${DOT_BREW_PREFIX:+"$DOT_BREW_PREFIX/etc/profile.d/bash_completion.sh"}; do
        [ -r "$file" ] && { info "already installed" "bash-completion"; return 0; }
    done
    pkg_install bash-completion || warn "continuing without bash-completion"
}
