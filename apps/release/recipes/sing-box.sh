# sing-box: https://github.com/SagerNet/sing-box/releases
release_repo=SagerNet/sing-box
release_bin=sing-box
release_asset() {
    local os=$1 cpu=$2
    [ "$os" = macos ] && os=darwin
    [ "$cpu" = x86_64 ] && cpu=amd64
    printf 'sing-box-%s-%s-%s.tar.gz\n' "${3#v}" "$os" "$cpu"
}
