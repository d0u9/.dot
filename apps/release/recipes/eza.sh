# eza: https://github.com/eza-community/eza/releases
# Tags carry the v; assets are eza_TARGET.tar.gz holding ./eza alone. Linux
# only: x86_64 uses the static musl build, arm64 has only a glibc build.
# There is no macOS build; the eza app installs it with Homebrew there.
release_repo=eza-community/eza
release_bin=eza
release_asset() {
    case $1-$2 in
        linux-x86_64) echo eza_x86_64-unknown-linux-musl.tar.gz ;;
        linux-arm64) echo eza_aarch64-unknown-linux-gnu.tar.gz ;;
        *) error "release: eza has no official $1-$2 build"; return 1 ;;
    esac
}
