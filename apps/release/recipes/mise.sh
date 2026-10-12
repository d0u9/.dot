# mise: https://github.com/jdx/mise/releases
# Assets are mise-TAG-OS-ARCH.tar.gz holding mise/bin/mise; Linux uses the
# static musl build and calls x86_64 x64.
release_repo=jdx/mise
release_bin=bin/mise
release_asset() {
    local arch=$2
    [ "$arch" = x86_64 ] && arch=x64
    case $1 in
        macos) printf 'mise-%s-macos-%s.tar.gz\n' "$3" "$arch" ;;
        linux) printf 'mise-%s-linux-%s-musl.tar.gz\n' "$3" "$arch" ;;
    esac
}
