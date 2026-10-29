desc="eza modern directory listing (official build on Linux, Homebrew on macOS)"
case $OSTYPE in linux*) release=(eza) ;; esac
# An executable bit does not prove the host has the binary's dynamic loader.
post() {
    local binary="$HOME/.local/bin/eza"
    if [ -x "$binary" ]; then
        "$binary" --version >/dev/null 2>&1 && return 0
        # Only remove our own incompatible release before trying a system package.
        if [ -L "$binary" ] && [ "$(readlink "$binary")" = ../lib/eza/current/eza ]; then
            release_uninstall eza
        fi
    fi
    pkg_install eza || warn "continuing without eza"
}
