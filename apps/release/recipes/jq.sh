# jq: https://github.com/jqlang/jq/releases (tags are jq-VERSION)
release_repo=jqlang/jq
release_bin=jq
release_format=binary
release_asset() {
    local cpu=$2
    [ "$cpu" = x86_64 ] && cpu=amd64
    printf 'jq-%s-%s\n' "$1" "$cpu"
}
