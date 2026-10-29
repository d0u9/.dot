# LLVM: https://github.com/llvm/llvm-project/releases
# Tags are llvmorg-23.1.4; assets are LLVM-23.1.4-{macOS-ARM64,Linux-X64,
# Linux-ARM64}.tar.xz, one top-level directory with bin/, lib/ and include/.
# clang finds its headers and runtime relative to bin/, so the tree stays
# whole. There is no macOS x86_64 build. Request a version as llvmorg-X.Y.Z.
release_repo=llvm/llvm-project
release_bin=bin/clang
release_links=(
    clang:bin/clang clang++:bin/clang++ clangd:bin/clangd
    clang-format:bin/clang-format clang-tidy:bin/clang-tidy
    lld:bin/lld ld.lld:bin/ld.lld lldb:bin/lldb
    llvm-ar:bin/llvm-ar llvm-nm:bin/llvm-nm llvm-objdump:bin/llvm-objdump
    llvm-symbolizer:bin/llvm-symbolizer llvm-config:bin/llvm-config
)
release_asset() {
    case $1-$2 in
        macos-arm64) printf 'LLVM-%s-macOS-ARM64.tar.xz\n' "${3#llvmorg-}" ;;
        linux-x86_64) printf 'LLVM-%s-Linux-X64.tar.xz\n' "${3#llvmorg-}" ;;
        linux-arm64) printf 'LLVM-%s-Linux-ARM64.tar.xz\n' "${3#llvmorg-}" ;;
        *) error "release: llvm has no official $1-$2 build"; return 1 ;;
    esac
}
