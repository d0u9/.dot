#! /bin/bash

DOT_DIR="$(pwd)/$(dirname "$0")"
# import auxiliary functions
export DOT_OMZ_DIR=$HOME/.dot/apps/omz
source "$DOT_DIR/apps/omz/lib.sh"

env_check_and_setup() {
    if ! set_gnu_realpath; then
        error "Cannot find GNU realpath, please install via `brew install coreutils`"
        exit 1
    fi
}

# $1: an empty array. On return, this array will be initialized as app names
find_install_scripts() {
    apps=()
    for file in "$APP_DIR"/*-install.sh; do
        file=$(basename $(realpath "$file"))
        app=$(echo "$file" | sed 's/-install.sh//')
        apps+=("$app")
    done
    echo "${apps[@]}"
}


print_help() {
    printf -- "-h: %-s\n" "Print this help"
    printf -- "-l: %-s\n" "List available apps to install"
}

list_apps() {
    local apps=("$@")
    for idx in ${!apps[@]}; do
        name=${apps[$idx]}
        printf "%-2s: %-s\n" "$idx" "$name"
    done
}

# $1: app name
# $2: the path of install script
install_app() {
    name="$1"
    install_script="$2"
    if ! yes_or_no "Really want to install [$name]"; then
        info "'N' is pressed, quit"
        exit 0
    fi

    DOT_LOG_LEVEL="$DOT_LOG_LEVEL" \
    APP_DIR="$APP_DIR" \
    DOT_DIR="$DOT_DIR" \
    exec "$install_script"
}

######################### MAIN #########################
env_check_and_setup
DOT_DIR=$(realpath "$DOT_DIR")
APP_DIR=$(realpath "$DOT_DIR/apps")
DOT_LOG_LEVEL="info"

apps=$(find_install_scripts)

while getopts ":hli:" opt; do
    case $opt in
        h)
            print_help
            ;;
        l)
            printf -- "-------------------------- Apps --------------------------\n"
            list_apps ${apps[@]}
            ;;
        i)
            name="$OPTARG"
            install_script=$(realpath "$APP_DIR/$name-install.sh" 2>/dev/null)
            if [ ! -f "$install_script" ]; then
                error "no [$name] app is found in $APP_DIR"
                exit 1
            fi

            install_app "$name" "$install_script"
            ;;
        *)
            error "unknown option: -$OPTARG"
            print_help
            ;;
    esac
done
