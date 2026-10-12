# fzf: https://github.com/junegunn/fzf/releases
# Tags are v0.74.5; assets are fzf-0.74.5-{darwin,linux}_{arm64,amd64}.tar.gz
# holding only the fzf executable.
release_repo=junegunn/fzf
release_bin=fzf
release_asset() {
    local os=$1 cpu=$2
    [ "$os" = macos ] && os=darwin
    [ "$cpu" = x86_64 ] && cpu=amd64
    printf 'fzf-%s-%s_%s.tar.gz\n' "${3#v}" "$os" "$cpu"
}
