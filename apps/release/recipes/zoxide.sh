# zoxide: https://github.com/ajeetdsouza/zoxide/releases
# Tags are v0.10.0; assets are zoxide-0.10.0-TARGET.tar.gz, unpacked flat with
# zoxide beside its man pages and completions. Linux has only musl builds.
release_repo=ajeetdsouza/zoxide
release_bin=zoxide
release_asset() { printf 'zoxide-%s-%s.tar.gz\n' "${3#v}" "$(release_rust_target "$1" "$2")"; }
