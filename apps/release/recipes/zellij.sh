# Zellij: https://github.com/zellij-org/zellij/releases
# Assets are zellij-TARGET.tar.gz holding only the zellij executable; Linux
# has only musl builds.
release_repo=zellij-org/zellij
release_bin=zellij
release_asset() { printf 'zellij-%s.tar.gz\n' "$(release_rust_target "$1" "$2")"; }
