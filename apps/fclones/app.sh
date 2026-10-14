desc="fclones duplicate file finder (system package)"
default_on=0
post() { pkg_install fclones || warn "continuing without fclones"; }
