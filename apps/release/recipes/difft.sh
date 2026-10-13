# difftastic: https://github.com/Wilfred/difftastic/releases
# Assets are difft-TAG-TARGET.tar.gz (tags have no v) holding only the difft
# executable. Linux x86_64 uses the static musl build; aarch64 has only gnu.
release_repo=Wilfred/difftastic
release_bin=difft
release_asset() {
    local target
    target=$(release_rust_target "$1" "$2")
    [ "$target" = aarch64-unknown-linux-musl ] && target=aarch64-unknown-linux-gnu
    printf 'difft-%s-%s.tar.gz\n' "$3" "$target"
}
