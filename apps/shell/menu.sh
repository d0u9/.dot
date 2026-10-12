#!/bin/bash

# app_menu: a checklist of the apps, each app's items indented below it and
# shown only while the app is ticked. Draws on /dev/tty and prints one
# APP:ITEM,... spec per ticked app. Ticked to begin with: installed apps and
# their recorded items; on a host with nothing recorded, every app and the
# default items.
app_menu() {
    local -a ids=() parents=() labels=() on=()
    local name item chosen parent any=
    [ -s "$APP_STATE" ] && any=1
    for name in $(app_names); do
        app_load "$name"
        if chosen=$(app_recorded "$name"); then on+=(1); else [ -n "$any" ] && on+=(0) || on+=(1); chosen=$(app_default_items); fi
        parent=${#ids[@]}
        ids+=("$name") parents+=(-) labels+=("$name - $desc")
        for item in ${items[@]+"${items[@]}"}; do
            item=${item%:on}
            ids+=("$item") parents+=("$parent") labels+=("$item")
            case ,$chosen, in *,"$item",*) on+=(1) ;; *) on+=(0) ;; esac
        done
    done
    (
        local n=${#ids[@]} cur=0 drawn=0 key i spec
        visible() { local p=${parents[$1]}; [ "$p" = - ] || [ "${on[p]}" = 1 ]; }
        move() {
            local i=$cur
            while i=$((i + $1)); [ "$i" -ge 0 ] && [ "$i" -lt "$n" ]; do
                visible "$i" && { cur=$i; return; }
            done
        }
        exec 3<> /dev/tty
        printf '\033[?25l' >&3
        trap 'printf "\033[?25h" >&3' EXIT
        while :; do
            [ "$drawn" -eq 0 ] || printf '\033[%dA' "$drawn" >&3
            printf '\033[J↑↓/jk move, space toggle, enter confirm, q quit\n' >&3
            drawn=1
            for ((i = 0; i < n; i++)); do
                visible "$i" || continue
                [ "$i" = "$cur" ] && printf '\033[7m' >&3
                printf '%s[%s] %s\033[0m\n' "$([ "${parents[i]}" = - ] || echo '    ')" \
                    "$([ "${on[i]}" = 1 ] && echo x || echo ' ')" "${labels[i]}" >&3
                drawn=$((drawn + 1))
            done
            IFS= read -rsn1 key <&3 || exit 1
            case $key in
                $'\033') read -rsn2 key <&3; case $key in '[A') move -1 ;; '[B') move 1 ;; esac ;;
                k) move -1 ;;
                j) move 1 ;;
                ' ') [ "${on[cur]}" = 1 ] && on[cur]=0 || on[cur]=1 ;;
                '') break ;;
                q) exit 1 ;;
            esac
        done
        spec=
        for ((i = 0; i < n; i++)); do
            if [ "${parents[i]}" = - ]; then
                [ -z "$spec" ] || echo "$spec"
                spec=; [ "${on[i]}" = 1 ] && spec=${ids[i]}:
            elif [ -n "$spec" ] && [ "${on[i]}" = 1 ]; then
                case $spec in *:) spec=$spec${ids[i]} ;; *) spec=$spec,${ids[i]} ;; esac
            fi
        done
        [ -z "$spec" ] || echo "$spec"
    )
}
