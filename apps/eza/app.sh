desc="eza modern directory listing (system package)"
post() { pkg_install eza || warn "continuing without eza"; }
