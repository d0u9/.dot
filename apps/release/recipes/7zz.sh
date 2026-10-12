# 7-Zip: https://github.com/ip7z/7zip/releases
# Tags are 26.04; assets are 7z2604-mac.tar.xz (one universal build) and
# 7z2604-linux-{arm64,x64}.tar.xz, unpacked flat. Unlike Homebrew's sevenzip,
# the official build includes the RAR codecs.
release_repo=ip7z/7zip
release_bin=7zz
release_asset() {
    case $1-$2 in
        macos-*) printf '7z%s-mac.tar.xz\n' "${3//./}" ;;
        linux-x86_64) printf '7z%s-linux-x64.tar.xz\n' "${3//./}" ;;
        *) printf '7z%s-linux-%s.tar.xz\n' "${3//./}" "$2" ;;
    esac
}
