# fd: https://github.com/sharkdp/fd/releases
# Assets are fd-TAG-TARGET.tar.gz (tags carry the v) with a top-level
# directory holding fd. Linux uses the static musl build.
release_repo=sharkdp/fd
release_bin=fd
release_asset() { printf 'fd-%s-%s.tar.gz\n' "$3" "$(release_rust_target "$1" "$2")"; }
