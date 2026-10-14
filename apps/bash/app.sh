desc="Bash for servers: configuration and bash-completion"
link=("bashrc:$HOME/.bashrc" "bash_profile:$HOME/.bash_profile")

# Completion is optional so a minimal server still receives a usable shell.
post() {
    local file package
    if command_exist brew; then
        # Probe PATH's Bash: install.sh itself may run under /bin/bash 3.2.
        package=$(bash -c 'if (( BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 2) )); then echo bash-completion@2; else echo bash-completion; fi') ||
            { warn "cannot determine Bash version; continuing without bash-completion"; return 0; }
        if [ -n "$(brew list --versions "$package" 2>/dev/null)" ]; then
            info "already installed" "$package"
        else
            pkg_install "$package" || warn "continuing without $package; check for a conflicting bash-completion formula"
        fi
        return 0
    fi
    for file in /usr/share/bash-completion/bash_completion /etc/bash_completion \
        ${DOT_BREW_PREFIX:+"$DOT_BREW_PREFIX/etc/profile.d/bash_completion.sh"}; do
        [ -r "$file" ] && { info "already installed" "bash-completion"; return 0; }
    done
    pkg_install bash-completion || warn "continuing without bash-completion"
}
