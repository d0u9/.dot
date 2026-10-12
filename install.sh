#! /bin/bash

set -euo pipefail

# Resolve the repo root from this script's own location so that the installer
# works no matter what directory it is invoked from.
DOT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
DOT_LOG_LEVEL=info
source "$DOT_DIR/apps/shell/apps.sh"
source "$DOT_DIR/apps/shell/menu.sh"

usage() {
    cat <<'HELP'
Usage: install.sh                     choose apps and items from a checklist
       install.sh APP[:ITEM,...]...   install or update apps
       install.sh -a                  install every app
       install.sh -u                  update every installed app
       install.sh -r APP...           uninstall apps
       install.sh -p APP...           delete the data apps generated
       install.sh -l                  list apps (* = installed)

An app's ITEMS are its optional parts; a bare APP that has them opens its
checklist on a terminal, and elsewhere keeps the last choice, or the app's
defaults on a first install. `APP:` chooses none. Unticking an
app in the checklist does not uninstall it; use -r.
HELP
}

# APP[:ITEMS]. A bare APP that has items asks for them on a terminal.
install_spec() {
    local spec
    case $1 in
        *:*) app_run install "${1%%:*}" "${1#*:}" ;;
        *)
            if [ -t 0 ] && (app_load "$1" > /dev/null 2>&1 && [ ${#items[@]} -gt 0 ]); then
                spec=$(app_menu "$1") || { info "cancelled"; return; }
                [ -z "$spec" ] || install_spec "$spec"
            else
                app_run install "$1"
            fi ;;
    esac
}

case ${1:-} in
    -h|--help) usage ;;
    -l) app_list ;;
    ''|-m)
        specs=$(app_menu) || { info "cancelled"; exit 1; }
        for spec in $specs; do install_spec "$spec"; done ;;
    -a) for name in $(app_names); do app_run install "$name"; done ;;
    -u)
        [ -f "$APP_STATE" ] || { info "no app is installed"; exit 0; }
        for name in $(awk '{ print $1 }' "$APP_STATE"); do app_run install "$name"; done ;;
    -r|-p)
        verb=uninstall; [ "$1" = -p ] && verb=purge
        shift
        [ $# -gt 0 ] || { usage >&2; exit 2; }
        for name in "$@"; do app_run "$verb" "$name"; done ;;
    -*) usage >&2; exit 2 ;;
    *) for spec in "$@"; do install_spec "$spec"; done ;;
esac

exit "$app_failed"
