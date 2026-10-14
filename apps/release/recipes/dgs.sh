# dgs-toolbox: https://github.com/d0u9/dgs-toolbox/releases
# Assets are dgs_vVERSION_OS_ARCH.tar.gz containing dgs at the root.
release_repo=d0u9/dgs-toolbox
release_bin=dgs
release_asset() {
    local os=$1 cpu=$2
    [ "$os" = macos ] && os=darwin
    [ "$cpu" = x86_64 ] && cpu=amd64
    printf 'dgs_v%s_%s_%s.tar.gz\n' "${3#v}" "$os" "$cpu"
}
