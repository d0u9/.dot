#!/bin/bash
set -euo pipefail
DOT_DIR=$(cd -- "$(dirname -- "$0")/../.." && pwd)
eza_test_dir=$(mktemp -d)
trap 'rm -rf -- "$eza_test_dir"' EXIT
export DOT_DIR eza_test_dir
env HOME="$eza_test_dir/home" PATH=/usr/bin:/bin bash --noprofile --norc <<'BASH'
set -euo pipefail
source "$DOT_DIR/apps/shell/apps.sh"
OSTYPE=linux-gnu
APP_STATE=$eza_test_dir/state/apps
mkdir -p "$eza_test_dir/fixture" "$eza_test_dir/system"
PATH="$RELEASE_BIN:$eza_test_dir/system:$PATH"
uname() { case $1 in -s) echo Linux ;; -m) echo aarch64 ;; esac; }
release_target() { echo 'v1.0.0 v1.0.0'; }
release_digest() { :; }
curl() {
    while [ $# -gt 0 ]; do
        if [ "$1" = -o ]; then cp "$eza_test_dir/eza.tar.gz" "$2"; return; fi
        shift
    done
    return 1
}
command_exist() {
    case $1 in
        brew|apt-get|dnf|pacman) return 1 ;;
        apk) return 0 ;;
        eza) [ -x "$RELEASE_BIN/eza" ] || [ -x "$eza_test_dir/system/eza" ] ;;
        *) command -v "$1" >/dev/null 2>&1 ;;
    esac
}
run_privileged() { "$@"; }
apk() {
    printf '#!/bin/sh\necho system-eza\n' > "$eza_test_dir/system/eza"
    chmod +x "$eza_test_dir/system/eza"
}

# Executable permission alone passes even when the dynamic loader is absent.
printf '#!/nonexistent-loader\n' > "$eza_test_dir/fixture/eza"
chmod +x "$eza_test_dir/fixture/eza"
tar -czf "$eza_test_dir/eza.tar.gz" -C "$eza_test_dir/fixture" eza
app_do_install eza
[ ! -L "$RELEASE_BIN/eza" ]
[ ! -d "$RELEASE_LIB/eza" ]
[ "$(eza --version)" = system-eza ]

# A working release stays installed and takes precedence over the system one.
printf '#!/bin/sh\necho release-eza\n' > "$eza_test_dir/fixture/eza"
tar -czf "$eza_test_dir/eza.tar.gz" -C "$eza_test_dir/fixture" eza
app_do_install eza
[ -L "$RELEASE_BIN/eza" ]
[ "$("$RELEASE_BIN/eza" --version)" = release-eza ]

# An incompatible executable belonging to another installer is left alone.
release_uninstall eza
printf '#!/nonexistent-loader\n' > "$eza_test_dir/fixture/eza"
ln -s "$eza_test_dir/fixture/eza" "$RELEASE_BIN/eza"
post
[ "$(readlink "$RELEASE_BIN/eza")" = "$eza_test_dir/fixture/eza" ]
[ -x "$eza_test_dir/fixture/eza" ]
echo 'Eza runtime compatibility and package fallback passed'
BASH
