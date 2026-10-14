# shadowsocks-rust: https://github.com/shadowsocks/shadowsocks-rust/releases
release_repo=shadowsocks/shadowsocks-rust
release_bin=sslocal
release_links=(sslocal:sslocal ssserver:ssserver ssmanager:ssmanager ssservice:ssservice ssurl:ssurl)
release_asset() { printf 'shadowsocks-v%s.%s.tar.xz\n' "${3#v}" "$(release_rust_target "$1" "$2")"; }
