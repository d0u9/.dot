#!/bin/bash

# Shared Bash/Zsh interactive helpers.
if [ -z "${BASH_VERSION:-}" ] && [ -z "${ZSH_VERSION:-}" ]; then
    echo "unknown shell, neither bash nor zsh" >&2
fi

_DOT_C_RESET=$'\033[0m'
_DOT_C_RED=$'\033[0;31m'
_DOT_C_GREEN=$'\033[0;32m'
_DOT_C_CYAN=$'\033[0;36m'
_DOT_C_LIGHTBLUE=$'\033[0;94m'
_DOT_C_ITALIC_CYAN=$'\033[3;36m'

_dlog_level() {
    case "$1" in
        'error') _dlog_lvl=1;;
        'warn')  _dlog_lvl=2;;
        'info')  _dlog_lvl=3;;
        'debug') _dlog_lvl=4;;
        *)       _dlog_lvl=2;;
    esac
}

dlog() {
    local level="$1"
    local msg="$2"
    local file="${3:-}"
    local _dlog_lvl threshold

    _dlog_level "${DOT_LOG_LEVEL:-info}"
    threshold=$_dlog_lvl
    _dlog_level "$level"
    [ "$_dlog_lvl" -le "$threshold" ] || return 0

    local head c
    case "$level" in
        'debug') head="${_DOT_C_GREEN}[D]${_DOT_C_RESET}"; c="$_DOT_C_LIGHTBLUE";;
        'info')  head="${_DOT_C_GREEN}[I]${_DOT_C_RESET}"; c="$_DOT_C_CYAN";;
        'warn')  head="${_DOT_C_GREEN}[W]${_DOT_C_RESET}"; c="$_DOT_C_CYAN";;
        'error') head="${_DOT_C_RED}[E]${_DOT_C_RESET}";   c="$_DOT_C_CYAN";;
        *)       head="${_DOT_C_GREEN}[?]${_DOT_C_RESET}"; c="$_DOT_C_RESET";;
    esac

    if [ -n "$file" ]; then
        file="[${_DOT_C_ITALIC_CYAN}${file}${_DOT_C_RESET}]"
    fi
    printf '%s: %s%-36s%s%s\n' "$head" "$c" "$msg" "$_DOT_C_RESET" "$file"
}

if [ -n "${BASH_VERSION:-}" ]; then
    export -f dlog _dlog_level
    export _DOT_C_RESET _DOT_C_RED _DOT_C_GREEN _DOT_C_CYAN \
           _DOT_C_LIGHTBLUE _DOT_C_ITALIC_CYAN
fi

debug() { dlog 'debug' "$1" "${2:-}"; }
info() { dlog 'info' "$1" "${2:-}"; }
warn() { dlog 'warn' "$1" "${2:-}"; }
error() { dlog 'error' "$1" "${2:-}"; }

command_exist() {
    command -v "$1" &> /dev/null
}

# Resolve Homebrew's installation prefix into $DOT_BREW_PREFIX, empty when this
# host has none. The prefix is fixed per platform and architecture, and both
# shells need it: Zsh evaluates `brew shellenv`, and Bash loads brew's own
# completion from it. Deciding it once here replaces a `uname -m` fork in
# core/homebrew.zsh and a `brew --prefix` fork in bash/completion.bash.
#
# $CPUTYPE and $HOSTTYPE report the architecture without forking. It only has
# to disambiguate a host carrying both an Apple Silicon and a Rosetta
# installation; anywhere else the executable test below decides on its own.
#
# No command substitution on the startup path: a `$(...)` costs a fork even for
# a builtin, and this runs in every interactive shell. Assigning through one
# would also abort the installer, which sources this file under `set -e`.
_dot_set_brew_prefix() {
    local candidate arch
    DOT_BREW_PREFIX=

    if [ -n "${ZSH_VERSION:-}" ]; then
        arch=$CPUTYPE
    else
        arch=${HOSTTYPE:-}
    fi

    set --
    case $OSTYPE in
        darwin*)
            case $arch in
                arm64|aarch64) set -- /opt/homebrew /usr/local;;
                *)             set -- /usr/local /opt/homebrew;;
            esac
            ;;
        linux*) set -- /home/linuxbrew/.linuxbrew "$HOME/.linuxbrew";;
    esac

    for candidate in "$@"; do
        if [ -x "$candidate/bin/brew" ]; then
            DOT_BREW_PREFIX=$candidate
            return 0
        fi
    done

    # An installation at a non-default prefix is reachable through PATH. Zsh
    # answers this from its command table; Bash has no fork-free equivalent, so
    # it pays a subshell here -- only on a host where neither default prefix
    # exists, which is every host without Homebrew.
    if [ -n "${ZSH_VERSION:-}" ]; then
        candidate=${commands[brew]:-}
    else
        candidate=$(type -P brew 2>/dev/null) || candidate=
    fi
    [ -n "$candidate" ] && [ -x "$candidate" ] || return 0
    # <prefix>/bin/brew -> <prefix>
    candidate=${candidate%/*}
    DOT_BREW_PREFIX=${candidate%/*}
}
_dot_set_brew_prefix
unset -f _dot_set_brew_prefix

# Prepend an existing directory once. Keep PATH exported for child processes.
_dot_prepend_path_if_dir() {
    local dir="$1"
    [ -d "$dir" ] || return 0
    case :$PATH: in
        *:"$dir":*) ;;
        *) PATH="$dir:$PATH";;
    esac
    export PATH
}

# Return $2 relative to $1 when it is underneath $1. Host hooks use this for
# log labels, so keep it in runtime helpers rather than installer-only code.
cur_path_relative() {
    local base="${1%/}"
    local cur="$2"
    case "$cur" in
        /*) ;;
        *) cur="$PWD/$cur";;
    esac
    case "$cur" in
        "$base"/*) printf '%s\n' "${cur#"$base"}";;
        *) printf '%s\n' "$cur";;
    esac
}

# Render lsof's machine-readable process/socket records without the wide
# DEVICE and SIZE/OFF columns. Command names retain spaces and truncate only
# after 24 characters.
_dot_format_lsof_ports() {
    awk '
        function compact(value) {
            gsub(/[[:space:]]+/, " ", value)
            return length(value) > 24 ? substr(value, 1, 21) "..." : value
        }
        BEGIN { printf "%-24s %-7s %-12s %-6s %s\n", "COMMAND", "PID", "USER", "FAMILY", "ADDRESS" }
        /^p/ { pid=substr($0, 2); next }
        /^c/ { command=substr($0, 2); next }
        /^u/ { user=substr($0, 2); next }
        /^L/ { user=substr($0, 2); next }
        /^t/ { family=substr($0, 2); next }
        /^n/ { printf "%-24s %-7s %-12s %-6s %s\n", compact(command), pid, user, family, substr($0, 2) }
    '
}

# Consume tab-separated FAMILY, INTERFACE, ADDRESS records. Print one row per
# interface so its name and MAC address do not repeat for each IP family.
_dot_ips_table() {
    awk -F '\t' '
        function append(existing, address) {
            return existing == "" ? address : existing ", " address
        }
        {
            family=$1; iface=$2; address=$3
            if (!(iface in seen)) order[++count]=iface
            seen[iface]=1
            if (family == "MAC") mac[iface]=address
            else if (family == "IPv4") ipv4[iface]=append(ipv4[iface], address)
            else if (family == "IPv6") ipv6[iface]=append(ipv6[iface], address)
        }
        END {
            printf "%-12s %-17s %-15s %s\n", "INTERFACE", "MAC", "IPv4", "IPv6"
            for (row = 1; row <= count; row++) {
                iface=order[row]
                if (ipv4[iface] != "" || ipv6[iface] != "")
                    printf "%-12s %-17s %-15s %s\n", iface, mac[iface] ? mac[iface] : "-", ipv4[iface] ? ipv4[iface] : "-", ipv6[iface] ? ipv6[iface] : "-"
            }
        }
    '
}

# List local non-loopback, non-link-local addresses in a consistent table.
# `ips public` queries ipify for public IPv4 and, when available, IPv6. Linux
# prefers iproute2; macOS and minimal Linux hosts fall back to ifconfig.
ips() {
    local address found=0 public_ipv4= public_ipv6=
    case ${1:-local} in
        public)
            command_exist curl || return 1
            if address=$(curl -4 -fs --connect-timeout 2 --max-time 5 https://api.ipify.org); then
                [ -n "$address" ] && public_ipv4=$address && found=1
            fi
            # api6 fails cleanly when this network has no IPv6 route.
            if address=$(curl -6 -fs --connect-timeout 2 --max-time 5 https://api6.ipify.org); then
                [ -n "$address" ] && public_ipv6=$address && found=1
            fi
            [ "$found" -eq 1 ] || return 1
            printf '%-12s %-17s %-15s %s\n' INTERFACE MAC IPv4 IPv6
            printf '%-12s %-17s %-15s %s\n' PUBLIC - "${public_ipv4:--}" "${public_ipv6:--}"
            return
            ;;
        local) ;;
        *)
            printf 'usage: ips [local|public]\n' >&2
            return 2
            ;;
    esac

    case $OSTYPE in
        darwin*)
            command_exist ifconfig || return 1
            ifconfig | awk '
                /^[[:alnum:]_.-]+:/ { iface=$1; sub(/:$/, "", iface); next }
                $1 == "ether" {
                    printf "MAC\t%s\t%s\n", iface, $2
                }
                $1 == "inet" {
                    if ($2 !~ /^127\./) printf "IPv4\t%s\t%s\n", iface, $2
                }
                $1 == "inet6" {
                    address=$2
                    sub(/%.*/, "", address)
                    if (address != "::1" && tolower(address) !~ /^fe80:/)
                        printf "IPv6\t%s\t%s\n", iface, address
                }
            ' | _dot_ips_table
            ;;
        linux*)
            if command_exist ip; then
                {
                    ip -o link show | awk '{
                    split($2, name, "@"); sub(/:$/, "", name[1])
                    for (field = 1; field <= NF; field++)
                        if ($field == "link/ether")
                            printf "MAC\t%s\t%s\n", name[1], $(field + 1)
                    }'
                    ip -o -4 addr show scope global | awk '{ split($2, name, "@"); sub(/\/.*/, "", $4); printf "IPv4\t%s\t%s\n", name[1], $4 }'
                    ip -o -6 addr show scope global | awk '{ split($2, name, "@"); sub(/\/.*/, "", $4); printf "IPv6\t%s\t%s\n", name[1], $4 }'
                } | _dot_ips_table
            elif command_exist ifconfig; then
                ifconfig | awk '
                    /^[^[:space:]]/ {
                        iface=$1
                        sub(/:$/, "", iface)
                        for (field = 1; field <= NF; field++)
                            if ($field == "HWaddr")
                                printf "MAC\t%s\t%s\n", iface, $(field + 1)
                        next
                    }
                    $1 == "ether" {
                        printf "MAC\t%s\t%s\n", iface, $2
                    }
                    $1 == "inet" {
                        address=$2
                        sub(/^addr:/, "", address)
                        if (address !~ /^127\./) printf "IPv4\t%s\t%s\n", iface, address
                    }
                    $1 == "inet6" {
                        address=$2 == "addr:" ? $3 : $2
                        sub(/^addr:/, "", address)
                        sub(/\/.*/, "", address)
                        if (address != "::1" && tolower(address) !~ /^fe80:/)
                            printf "IPv6\t%s\t%s\n", iface, address
                    }
                ' | _dot_ips_table
            else
                return 1
            fi
            ;;
        *) return 1;;
    esac
}

# Report whether sudo currently runs without a password, without prompting.
# `sudo -n -l` lists the matching rules in parse order, and for sudoers the
# last match wins, so the final `ALL` rule decides. A NOPASSWD rule followed
# by a PASSWD one -- as cloud images add in their own drop-ins -- still
# prompts. When listing itself needs a password, the answer is "prompts".
_dot_sudo_nopasswd_active() {
    sudo -n -l 2>/dev/null |
        awk '/PASSWD: ?ALL$/ { last = $0 } END { exit !(last ~ /NOPASSWD: ?ALL$/) }'
}

# Toggle passwordless sudo for the current user through a drop-in under
# /etc/sudoers.d. Linux only. Usage: sudo_nopasswd [on|off|status], toggling
# when no argument is given. The rule is validated with `visudo -c` before it
# is installed: a malformed sudoers file locks everyone out of sudo.
#
# Drop-ins are read in lexical order and the last matching rule wins, so the
# file is named `zz-` to sort after numbered ones such as cloud-init's, which
# may grant the same user a PASSWD rule. Sudo ignores drop-in names containing
# '.' or ending in '~', so the name replaces anything outside [A-Za-z0-9_-];
# the rule inside keeps the real user name. `off` also removes the file an
# earlier version installed as `90-nopasswd-<user>`.
sudo_nopasswd() {
    local user name file legacy tmp action rc
    case $OSTYPE in
        linux*) ;;
        *) error "sudo_nopasswd: Linux only"; return 1;;
    esac
    command_exist sudo || { error "sudo_nopasswd: sudo not installed"; return 1; }
    command_exist visudo || [ -x /usr/sbin/visudo ] || {
        error "sudo_nopasswd: visudo not found"; return 1; }

    user=${USER:-$(id -un)}
    if [ "$user" = root ]; then
        error "sudo_nopasswd: refusing to run as root"
        return 1
    fi
    name=$(printf '%s' "$user" | tr -c 'A-Za-z0-9_-' '_')
    file="/etc/sudoers.d/zz-nopasswd-$name"
    legacy="/etc/sudoers.d/90-nopasswd-$name"

    action=${1:-toggle}
    if [ "$action" = toggle ]; then
        if _dot_sudo_nopasswd_active; then action=off; else action=on; fi
    fi

    case $action in
        on)
            tmp=$(mktemp) || return 1
            printf '%s ALL=(ALL) NOPASSWD: ALL\n' "$user" > "$tmp"
            if ! sudo env PATH="$PATH:/usr/sbin:/sbin" visudo -cqf "$tmp"; then
                rm -f "$tmp"
                error "sudo_nopasswd: rule failed validation"
                return 1
            fi
            sudo install -o root -g root -m 0440 "$tmp" "$file"
            rc=$?
            rm -f "$tmp"
            [ "$rc" -eq 0 ] || return "$rc"
            sudo rm -f "$legacy"
            if _dot_sudo_nopasswd_active; then
                printf '%s (%s)\n' "sudo password disabled for $user" "$file"
            else
                error "sudo_nopasswd: installed $file, but a later rule still asks for a password"
                return 1
            fi
            ;;
        off)
            sudo rm -f "$file" "$legacy" || return 1
            # Drop the cached credential so the change is visible at once.
            sudo -k
            printf '%s\n' "sudo password enabled for $user"
            ;;
        status)
            if _dot_sudo_nopasswd_active; then
                printf '%s\n' "sudo password disabled for $user"
            else
                printf '%s\n' "sudo password enabled for $user"
            fi
            ;;
        *)
            printf 'usage: sudo_nopasswd [on|off|status]\n' >&2
            return 2
            ;;
    esac
}
