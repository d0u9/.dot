desc="aria2 HTTP, FTP and BitTorrent downloader (system package)"
default_on=0
post() { pkg_install aria2 aria2c || warn "continuing without aria2"; }
