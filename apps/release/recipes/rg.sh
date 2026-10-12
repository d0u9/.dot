# ripgrep: https://github.com/BurntSushi/ripgrep/releases
# Tags are 15.2.0; assets are ripgrep-VERSION-TARGET.tar.gz with a top-level
# directory holding rg. Linux uses the static musl build, which runs on any
# glibc and is the only x86_64 Linux asset.
release_repo=BurntSushi/ripgrep
release_bin=rg
release_asset() { printf 'ripgrep-%s-%s.tar.gz\n' "$3" "$(release_rust_target "$1" "$2")"; }
