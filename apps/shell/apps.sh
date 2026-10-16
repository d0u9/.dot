#!/bin/bash

# Install, update and uninstall the apps under apps/NAME/app.sh. An app file
# declares what the app owns and the engine acts on the declarations:
#
#   desc="one line"            shown by `install.sh -l`
#   default_on=0               leave unchecked on a new host's checklist
#   release=(NAME[@VER] ...)   dgspkg tools, installed first; VER is a version
#                              or channel (default: the tool's saved channel)
#   git=("DEST URL" ...)       checkouts, cloned or fast-forwarded
#   link=("SRC:DEST" ...)      SRC relative to the app directory, `.` for it
#   link_replace=0            refuse foreign destinations; never restore .bk
#   items=(NAME[:on] ...)      optional parts; :on ones are chosen by default
#   item_install NAME, item_uninstall NAME
#   post                       anything else, run last with $APP_DIR set
#   data=(PATH ...)            generated data, deleted only by purge
#
# Installing is idempotent, so updating an app is installing it again.
# Uninstalling reverses the declarations, restoring a link's .bk backup; it
# leaves generated data and system packages alone; purge deletes the data. The installed apps and
# their chosen items are recorded in $APP_STATE, one `NAME ITEM,...` line each.

source "$DOT_DIR/apps/shell/release.sh"

APPS_DIR=$DOT_DIR/apps
APP_STATE=${XDG_STATE_HOME:-$HOME/.local/state}/dot/apps
# Tools installed by `release` are needed by `post` in the same run.
export PATH="$RELEASE_BIN:$PATH"
app_failed=0

app_names() {
    local file
    for file in "$APPS_DIR"/*/app.sh; do
        [ -f "$file" ] && basename -- "$(dirname -- "$file")"
    done
}

app_load() {
    desc= default_on=1 link_replace=1 release=() git=() link=() items=() data=()
    unset -f post item_install item_uninstall
    APP_NAME=$1 APP_DIR=$APPS_DIR/$1
    [ -f "$APP_DIR/app.sh" ] || { error "no app $1 in $APPS_DIR"; return 1; }
    source "$APP_DIR/app.sh"
}

# Print the recorded items of NAME; fail when NAME is not recorded.
app_recorded() {
    [ -f "$APP_STATE" ] && awk -v n="$1" '$1 == n { print $2; found = 1 } END { exit !found }' "$APP_STATE"
}

# Record NAME with ITEMS, or forget it when ITEMS is `-`.
app_record() {
    local tmp
    mkdir -p -- "$(dirname -- "$APP_STATE")"
    tmp=$(mktemp "$APP_STATE.XXXXXX")
    {
        [ ! -f "$APP_STATE" ] || awk -v n="$1" '$1 != n' "$APP_STATE"
        [ "$2" = - ] || echo "$1 $2"
    } > "$tmp"
    mv -- "$tmp" "$APP_STATE"
}

app_default_items() {
    local item out=
    for item in ${items[@]+"${items[@]}"}; do
        case $item in *:on) out=${out:+$out,}${item%:on} ;; esac
    done
    echo "$out"
}

app_link_src() {
    local src=${1%%:*}
    [ "$src" = . ] && _dot_abspath "$APP_DIR" || _dot_abspath "$APP_DIR/$src"
}

app_git() {
    local dest=$1 url=$2
    info "updating $url" "$dest"
    if [ -d "$dest/.git" ] && [ "$(git -C "$dest" remote get-url origin 2> /dev/null)" = "$url" ]; then
        git -C "$dest" pull --ff-only
    else
        # A checkout from a different url, such as a fork that was switched
        # away from, would otherwise keep fetching from the old remote.
        rm -fr -- "$dest"
        git clone --depth=1 "$url" "$dest"
    fi
}

# NAME [ITEMS]: without ITEMS, the recorded choice, else the defaults.
app_do_install() {
    local name=$1 chosen old rec spec ver item dest failed=
    app_load "$name"
    if old=$(app_recorded "$name"); then rec=1; else old= rec=; fi
    if [ $# -ge 2 ]; then chosen=$2; elif [ -n "$rec" ]; then chosen=$old; else chosen=$(app_default_items); fi
    for item in ${chosen//,/ }; do
        case " ${items[*]-} " in *" $item "*|*" $item:on "*) ;; *) error "$name has no item $item"; return 1 ;; esac
    done
    info "installing $name${chosen:+ ($chosen)}"
    # A tool that fails is reported, but the configuration is still put in place.
    for spec in ${release[@]+"${release[@]}"}; do
        ver=
        case $spec in *@*) ver=${spec#*@} ;; esac
        release_install "${spec%%@*}" "$ver" ||
            { warn "$name: $spec failed; continuing"; failed=1; }
    done
    for spec in ${git[@]+"${git[@]}"}; do
        app_git ${spec}
    done
    for spec in ${link[@]+"${link[@]}"}; do
        dest=${spec#*:}
        mkdir -p -- "$(dirname -- "$dest")"
        link_config "$(app_link_src "$spec")" "$(_dot_abspath "$dest")" "$link_replace"
    done
    # Recorded before the items and post run, so an app whose later step
    # fails can still be uninstalled; installing again retries that step.
    app_record "$name" "$chosen"
    for item in ${old//,/ }; do
        case ,$chosen, in *,"$item",*) ;; *) item_uninstall "$item" ;; esac
    done
    for item in ${chosen//,/ }; do
        item_install "$item"
    done
    ! declare -F post > /dev/null || post
    [ -z "$failed" ]
}

# Inside the repository only ignored files go, so tracked notes such as a
# README stay; -ff also takes the plugin checkouts, which are repositories.
app_do_purge() {
    local path
    app_load "$1"
    [ ${#data[@]} -gt 0 ] || { info "$1 declares no data"; return 0; }
    yes_or_no "delete the data of $1: ${data[*]}" || return 0
    for path in "${data[@]}"; do
        [ -e "$path" ] || continue
        case $path in
            "$DOT_DIR"/*) git -C "$DOT_DIR" clean -ffdXq -- "$path" ;;
            *) rm -fr -- "$path" ;;
        esac
        info "removed" "$path"
    done
}

# Release names of the recorded apps other than NAME.
app_releases_except() {
    local other spec
    [ -f "$APP_STATE" ] || return 0
    awk '{ print $1 }' "$APP_STATE" | while read -r other; do
        [ "$other" = "$1" ] && continue
        ( app_load "$other" > /dev/null 2>&1 &&
            for spec in ${release[@]+"${release[@]}"}; do echo "${spec%%@*}"; done ) || true
    done
}

app_do_uninstall() {
    local name=$1 chosen spec item src dest kept tool
    app_load "$name"
    chosen=$(app_recorded "$name") || chosen=
    info "uninstalling $name"
    for item in ${chosen//,/ }; do
        item_uninstall "$item"
    done
    for spec in ${link[@]+"${link[@]}"}; do
        src=$(app_link_src "$spec")
        dest=$(_dot_abspath "${spec#*:}" 2> /dev/null) || continue
        [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ] || continue
        rm -- "$dest"
        if [ "$link_replace" = 1 ] && [ -e "$dest.bk" ]; then
            mv -- "$dest.bk" "$dest"
            info "restored" "$dest"
        else
            info "removed" "$dest"
        fi
    done
    for spec in ${git[@]+"${git[@]}"}; do
        rm -fr -- "${spec%% *}"
    done
    kept=" $(app_releases_except "$name" | tr '\n' ' ') "
    for spec in ${release[@]+"${release[@]}"}; do
        tool=${spec%%@*}
        case $kept in
            *" $tool "*) info "kept, another app uses it" "$tool" ;;
            *) release_uninstall "$tool" ;;
        esac
    done
    app_record "$name" -
}

# VERB NAME [ITEMS]: run one app action with errexit in force. Failures are
# reported and counted in app_failed instead of stopping the run. Do not call
# this from an `if` or `||`: Bash then ignores errexit inside it.
app_run() {
    local rc
    set +e
    ( set -e; "app_do_$1" "${@:2}" )
    rc=$?
    set -e
    [ "$rc" -eq 0 ] || { error "[$2] $1 failed"; app_failed=1; }
}

app_list() {
    local name chosen mark
    for name in $(app_names); do
        if chosen=$(app_recorded "$name"); then mark='*'; else mark=' ' chosen=; fi
        ( app_load "$name" && printf '%s %-10s %s%s\n' "$mark" "$name" "$desc" \
            "$([ ${#items[@]} -eq 0 ] || echo " [items: ${items[*]}]${chosen:+ chosen: $chosen}")" )
    done
}
