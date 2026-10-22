# rclone: https://github.com/rclone/rclone/releases
# Assets are rclone-TAG-OS-CPU.zip (tags carry the v, macOS is osx) with a
# top-level directory holding rclone and its man page.
release_repo=rclone/rclone
release_bin=rclone
release_asset() {
    local os=$1 cpu=$2
    [ "$os" = macos ] && os=osx
    [ "$cpu" = x86_64 ] && cpu=amd64
    printf 'rclone-v%s-%s-%s.zip\n' "${3#v}" "$os" "$cpu"
}
