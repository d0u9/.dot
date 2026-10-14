#!/bin/bash
set -euo pipefail
DOT_DIR=$(cd -- "$(dirname -- "$0")/../.." && pwd)
source "$DOT_DIR/apps/shell/apps.sh"
source "$DOT_DIR/apps/shell/menu.sh"

release_load dgs
[ "$release_bin" = dgs ]
[ "$(release_asset macos arm64 v0.1.1)" = dgs_v0.1.1_darwin_arm64.tar.gz ]
[ "$(release_asset macos x86_64 0.1.1)" = dgs_v0.1.1_darwin_amd64.tar.gz ]
[ "$(release_asset linux arm64 v0.1.1)" = dgs_v0.1.1_linux_arm64.tar.gz ]
[ "$(release_asset linux x86_64 0.1.1)" = dgs_v0.1.1_linux_amd64.tar.gz ]

# Stop before opening the terminal and assert the menu's initial selection.
app_names() { printf '%s\n' dgs cli; }
app_recorded() { [ "$1" = "${recorded:-}" ]; }
menu_definition=$(declare -f app_menu)
menu_assert='[ "${on[*]}" = "$expected" ] || exit 1; exit 0'
menu_definition=${menu_definition/exec 3<> \/dev\/tty/$menu_assert}
eval "$menu_definition"
APP_STATE=/dev/null
expected='0 1'
app_menu
expected=1
app_menu dgs
recorded=dgs
expected='1 1'
app_menu
APP_STATE=$DOT_DIR/apps/dgs/app.sh
expected='1 0'
app_menu
echo 'dgs assets and checklist defaults passed'
