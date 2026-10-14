desc="macOS Homebrew coreutils, diffutils and Bash completion"
case $OSTYPE in darwin*) default_on=1 ;; *) default_on=0 ;; esac
post() {
    case $OSTYPE in darwin*) ;; *) return 0 ;; esac
    command_exist brew || { warn "Homebrew is required for macOS packages"; return 0; }
    local package
    for package in coreutils diffutils; do
        pkg_install "$package" || warn "continuing without $package"
    done
    # Reuse the Bash app's version-aware completion installation without linking config.
    (app_load bash; post)
}
