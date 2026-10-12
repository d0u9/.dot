# Neovim: https://github.com/neovim/neovim/releases
# Assets are nvim-{macos,linux}-{arm64,x86_64}.tar.gz with a top-level
# nvim-OS-ARCH/ directory; nvim finds its runtime relative to bin/nvim.
release_repo=neovim/neovim
release_bin=bin/nvim
release_asset() { printf 'nvim-%s-%s.tar.gz\n' "$1" "$2"; }

# stable and latest are the newest release. nightly is a prerelease rebuilt
# under the fixed tag `nightly`; its build version, such as
# v0.13.0-dev-1830+g89370c06d7, names the directory so each build is new.
release_channels="stable latest nightly"
release_default=stable
release_resolve() {
    local version
    case $1 in
        nightly)
            version=$(curl -fsS "https://api.github.com/repos/$release_repo/releases/tags/nightly" |
                grep -o 'NVIM v[^\\" ]*' | head -n 1) && [ -n "$version" ] ||
                { error "release: cannot read the nvim nightly version" >&2; return 1; }
            printf '%s nightly\n' "${version#NVIM }" ;;
        *) release_github_latest ;;
    esac
}
