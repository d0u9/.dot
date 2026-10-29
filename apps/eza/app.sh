desc="eza modern directory listing (official build on Linux, Homebrew on macOS)"
case $OSTYPE in linux*) release=(eza) ;; esac
# The system package covers macOS and a Linux host the release cannot serve
# (musl arm64), and is skipped once the release is in place.
post() { [ -x "$HOME/.local/bin/eza" ] || pkg_install eza || warn "continuing without eza"; }
