# bottom: https://github.com/ClementTsang/bottom/releases
# Assets are bottom_TARGET.tar.gz with the btm executable at the root.
release_repo=ClementTsang/bottom
release_bin=btm
release_asset() { printf 'bottom_%s.tar.gz\n' "$(release_rust_target "$1" "$2")"; }
