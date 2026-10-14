#!/bin/bash
set -euo pipefail
DOT_DIR=$(cd -- "$(dirname -- "$0")/../.." && pwd)
source "$DOT_DIR/apps/shell/apps.sh"
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
RELEASE_LIB=$tmp/lib
RELEASE_BIN=$tmp/bin

release_load jq
[ "$release_format" = binary ]
[ "$(release_asset macos arm64 jq-1.8.2)" = jq-macos-arm64 ]
[ "$(release_asset macos x86_64 jq-1.8.2)" = jq-macos-amd64 ]
[ "$(release_asset linux arm64 jq-1.8.2)" = jq-linux-arm64 ]
[ "$(release_asset linux x86_64 jq-1.8.2)" = jq-linux-amd64 ]
(
    fixture=$tmp/raw
    printf '#!/bin/sh\necho raw-binary\n' > "$fixture"
    curl() {
        while [ $# -gt 0 ]; do
            if [ "$1" = -o ]; then cp "$fixture" "$2"; return; fi
            shift
        done
        return 1
    }
    release_digest() { release_sha256 "$fixture"; }
    release_fetch jq jq-1.8.2 jq-1.8.2
    [ "$("$RELEASE_LIB/jq/jq-1.8.2/jq")" = raw-binary ]
)
release_load age
[ "$release_format" = archive ]

for name in sing-box shadowsocks-rust age; do
    app_load "$name"
    [ "$default_on" = 0 ]
    [ "${release[*]}" = "$name" ]
    release_load "$name"
    for os in macos linux; do
        for cpu in arm64 x86_64; do
            case $os in macos) platform=darwin ;; *) platform=linux ;; esac
            case $cpu in x86_64) arch=amd64 ;; *) arch=arm64 ;; esac
            case $name in
                sing-box) expected=sing-box-1.0.0-$platform-$arch.tar.gz ;;
                age) expected=age-v1.0.0-$platform-$arch.tar.gz ;;
                shadowsocks-rust)
                    case $cpu in arm64) arch=aarch64 ;; *) arch=x86_64 ;; esac
                    case $os in macos) target=$arch-apple-darwin ;; *) target=$arch-unknown-linux-musl ;; esac
                    expected=shadowsocks-v1.0.0.$target.tar.xz ;;
            esac
            [ "$(release_asset "$os" "$cpu" v1.0.0)" = "$expected" ]
        done
    done
done

# Exercise real installation and removal using generated binaries, without network.
release_target() { printf '%s v%s\n' "$1" "$1"; }
release_fetch() {
    local spec
    mkdir -p "$RELEASE_LIB/$1/$2"
    for spec in "${release_links[@]}"; do
        printf '#!/bin/sh\nexit 0\n' > "$RELEASE_LIB/$1/$2/${spec#*:}"
        chmod +x "$RELEASE_LIB/$1/$2/${spec#*:}"
    done
}
for name in age shadowsocks-rust dgs; do
    release_install "$name" 1
    for spec in "${release_links[@]}"; do
        [ -x "$RELEASE_BIN/${spec%%:*}" ]
    done
    # Installing the same version repairs a missing command link.
    rm "$RELEASE_BIN/${release_links[0]%%:*}"
    release_install "$name" 1
    [ -x "$RELEASE_BIN/${release_links[0]%%:*}" ]
    release_install "$name" 2
    release_install "$name" 3
    [ ! -d "$RELEASE_LIB/$name/1" ]
    [ -d "$RELEASE_LIB/$name/2" ]
    [ "$(release_current "$name")" = 3 ]
    # Uninstall must preserve a link that another owner has replaced.
    replaced=$RELEASE_BIN/${release_links[0]%%:*}
    ln -sfn "$tmp/other" "$replaced"
    release_uninstall "$name"
    [ -L "$replaced" ]
    for spec in "${release_links[@]:1}"; do
        [ ! -L "$RELEASE_BIN/${spec%%:*}" ]
    done
    [ ! -d "$RELEASE_LIB/$name" ]
    rm "$replaced"
done

release_install age 1
rm "$RELEASE_BIN/age-keygen"
printf 'keep\n' > "$RELEASE_BIN/age-keygen"
if release_install age 2 >/dev/null 2>&1; then echo 'overwrote an existing file' >&2; exit 1; fi
[ "$(cat "$RELEASE_BIN/age-keygen")" = keep ]
[ "$(release_current age)" = 1 ]
rm "$RELEASE_BIN/age-keygen" "$RELEASE_LIB/age/1/age-keygen"
if release_install age 1 >/dev/null 2>&1; then echo 'accepted a missing executable' >&2; exit 1; fi
for check in '' -u; do
    release_list "$check" | awk '
        NR == 1 { column = index($0, "CHANNEL") }
        $1 == "shadowsocks-rust" {
            found = 1
            if (substr($0, column, 1) != "-") exit 1
        }
        END { if (!found) exit 1 }
    '
done
echo 'Release assets, opt-in defaults and command lifecycle passed'
