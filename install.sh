#! /bin/bash

set -euo pipefail

# Resolve the repo root from this script's own location so that the installer
# works no matter what directory it is invoked from.
DOT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
APP_DIR="$DOT_DIR/apps"
DOT_LOG_LEVEL="info"

# import auxiliary functions
export DOT_OMZ_DIR="$APP_DIR/omz"
source "$APP_DIR/omz/lib.sh"

# Echo the installable app names. Anything called test* is scaffolding and is
# hidden here, though `-i test1` still reaches it.
find_install_scripts() {
    local file app
    for file in "$APP_DIR"/*-install.sh; do
        [ -f "$file" ] || continue
        app=$(basename "$file")
        app=${app%-install.sh}
        case "$app" in
            test*) continue;;
        esac
        echo "$app"
    done
}

print_help() {
    printf -- "-h: %-s\n" "Print this help"
    printf -- "-i [app]: %-s\n" "Install this app, may be repeated"
    printf -- "-a: %-s\n" "Install every app"
    printf -- "-l: %-s\n" "List available apps to install"
}

list_apps() {
    local idx=0 name
    for name in "$@"; do
        printf "%-2s: %-s\n" "$idx" "$name"
        idx=$((idx + 1))
    done
}

# $1: app name
install_app() {
    local name="$1"
    local install_script="$APP_DIR/$name-install.sh"

    if [ ! -f "$install_script" ]; then
        error "no [$name] app is found in $APP_DIR"
        return 1
    fi

    if ! yes_or_no "Really want to install [$name]"; then
        info "'N' is pressed, skip [$name]"
        return 0
    fi

    # A failing installer should not take the rest of the run down with it.
    if ! DOT_LOG_LEVEL="$DOT_LOG_LEVEL" \
        APP_DIR="$APP_DIR" \
        DOT_DIR="$DOT_DIR" \
        DOT_OMZ_DIR="$DOT_OMZ_DIR" \
        "$install_script"; then
        error "[$name] failed to install"
        return 1
    fi
}

######################### MAIN #########################
apps=()
while IFS= read -r line; do
    apps+=("$line")
done < <(find_install_scripts)

failed=0

if [ "$#" -eq 0 ]; then
    print_help
    exit 0
fi

while getopts ":hlai:" opt; do
    case $opt in
        h)
            print_help
            ;;
        l)
            printf -- "-------------------------- Apps --------------------------\n"
            list_apps "${apps[@]}"
            ;;
        a)
            for name in "${apps[@]}"; do
                install_app "$name" || failed=1
            done
            ;;
        i)
            install_app "$OPTARG" || failed=1
            ;;
        *)
            error "unknown option: -$OPTARG"
            print_help
            exit 1
            ;;
    esac
done

exit "$failed"
