#!/bin/bash
set -euo pipefail
DOT_DIR=$(cd -- "$(dirname -- "$0")/../.." && pwd)
source "$DOT_DIR/apps/shell/apps.sh"
command_exist() { [ "$1" = brew ]; }
pkg_install() { echo "$1"; }
warn() { :; }
# Stub only the nested Bash installer; keep macos/eza/jq declarations real.
eval "$(declare -f app_load | sed '1s/app_load/original_app_load/')"
app_load() {
    if [ "$1" = bash ]; then post() { echo completion; }
    else original_app_load "$1"
    fi
}
OSTYPE=linux-gnu
app_load macos
[ "$default_on" = 0 ]
[ -z "$(post)" ]
OSTYPE=darwin
app_load macos
[ "$default_on" = 1 ]
[ "$(post)" = $'coreutils\ndiffutils\ncompletion' ]
command_exist() { return 1; }
[ -z "$(post)" ]
app_load eza
[ "$default_on" = 1 ]
[ "$(post)" = eza ]
app_load jq
[ "$default_on" = 1 ]
[ "${release[*]}" = jq ]
echo 'macOS-only packages and default selections passed'
