# age: https://github.com/FiloSottile/age/releases
release_repo=FiloSottile/age
release_bin=age
release_links=(age:age age-keygen:age-keygen)
release_asset() {
    local os=$1 cpu=$2
    [ "$os" = macos ] && os=darwin
    [ "$cpu" = x86_64 ] && cpu=amd64
    printf 'age-v%s-%s-%s.tar.gz\n' "${3#v}" "$os" "$cpu"
}
