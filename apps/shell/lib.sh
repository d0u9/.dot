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

# Listening sockets as one table, whichever tool the shells selected for
# `ports` from apps/shell/fallbacks. Each backend parser emits tab-separated
# PROTO, ADDRESS, PORT, PID, COMMAND, USER records; a field the tool cannot
# report is "-". Records are deduplicated (lsof lists one per descriptor, so
# a forking server repeats), sorted, then laid out with computed widths.
# The shells' `ports` functions only pass their selected tool and arguments.
#
# Without root, lsof lists only this user's sockets and ss/netstat omit the
# process of sockets owned by others; -s runs the tool through sudo.

# Split ADDRESS:PORT at the last colon, dropping IPv6 brackets.
_DOT_PORTS_AWK_SPLIT='
function emit(proto, local, pid, command, user,    address, port) {
    sub(/->.*/, "", local)
    port = local; sub(/.*:/, "", port)
    # An unbound UDP socket (*:*) has no port to list.
    if (port !~ /^[0-9]+$/) return
    address = local; sub(/:[^:]*$/, "", address)
    gsub(/[][]/, "", address)
    gsub(/[[:space:]]+/, " ", command)
    if (length(command) > 32) command = substr(command, 1, 29) "..."
    if (address == "") address = "*"
    if (pid == "") pid = "-"
    if (command == "") command = "-"
    if (user == "") user = "-"
    printf "%s\t%s\t%s\t%s\t%s\t%s\n", proto, address, port, pid, command, user
}'

_dot_ports_lsof() {
    awk "$_DOT_PORTS_AWK_SPLIT"'
        /^p/ { pid = substr($0, 2); next }
        /^c/ { command = substr($0, 2); next }
        /^L/ { user = substr($0, 2); next }
        /^P/ { proto = tolower(substr($0, 2)); next }
        /^n/ { emit(proto, substr($0, 2), pid, command, user) }
    '
}

# ss and netstat print one protocol per run here, so the parser is told which.
_dot_ports_ss() {
    awk -v proto="$1" "$_DOT_PORTS_AWK_SPLIT"'
        NR == 1 && $1 == "State" { next }
        {
            pid = ""; command = ""; process = ""
            for (field = 6; field <= NF; field++) process = process $field
            if (match(process, /"[^"]*"/)) command = substr(process, RSTART + 1, RLENGTH - 2)
            if (match(process, /pid=[0-9]+/)) pid = substr(process, RSTART + 4, RLENGTH - 4)
            emit(proto, $4, pid, command, "")
        }
    '
}

_dot_ports_netstat() {
    awk -v proto="$1" "$_DOT_PORTS_AWK_SPLIT"'
        $1 !~ /^(tcp|udp)/ { next }
        {
            # PID/Program follows State for TCP; UDP has no State column.
            # The program name may itself contain blanks, as in "sshd: user".
            pid = ""; command = ""; process = ""
            for (field = ($1 ~ /^tcp/ ? 7 : 6); field <= NF; field++)
                process = process (process == "" ? "" : " ") $field
            if (process ~ /^[0-9]+\//) {
                pid = process; sub(/\/.*/, "", pid)
                command = process; sub(/^[0-9]+\//, "", command)
            }
            emit(proto, $4, pid, command, "")
        }
    '
}

_dot_ports_table() {
    awk -F '\t' '
        BEGIN {
            split("PROTO ADDRESS PORT PID COMMAND USER", head, " ")
            for (column = 1; column <= 6; column++) width[column] = length(head[column])
        }
        {
            rows[NR] = $0
            for (column = 1; column <= 6; column++)
                if (length($column) > width[column]) width[column] = length($column)
        }
        END {
            # The last column is not padded, so lines carry no trailing blanks.
            for (column = 1; column < 6; column++) format[column] = "%-" width[column] "s  "
            format[6] = "%s\n"
            for (column = 1; column <= 6; column++) printf format[column], head[column]
            for (row = 1; row <= NR; row++) {
                split(rows[row], field, "\t")
                for (column = 1; column <= 6; column++) printf format[column], field[column]
            }
        }
    '
}

_dot_ports_help() {
    cat <<'HELP'
Usage: ports [OPTION]...
List listening sockets as a table of PROTO, ADDRESS, PORT, PID, COMMAND
and USER. Fields the underlying tool cannot report are shown as "-".

Protocol (the last one given wins):
  -t              TCP listening sockets (default)
  -u              UDP sockets bound to a port
  -a              both TCP and UDP

Ordering:
  -o KEY, --order=KEY
                  sort rows by KEY; ties are broken by port:
                    port   port number (default)
                    addr   listening address (alias: address)
                    name   process name (alias: command)

Privileges:
  -s, --sudo      run the underlying tool through sudo. Without root,
                  lsof lists only your own sockets, and ss or netstat
                  omit the PID and COMMAND of sockets owned by others.

Other:
  -h, --help      show this help and exit

Short options combine: -su, -ao name, -soaddr.
The tool is lsof on macOS, and ss or else netstat on Linux; USER is
reported only by lsof.

Examples:
  ports              TCP listeners, ordered by port
  ports -a -o name   TCP and UDP, ordered by process name
  ports -so addr     TCP listeners of every user, ordered by address
HELP
}

_dot_ports_usage() {
    printf 'usage: ports [-s] [-t|-u|-a] [-o port|addr|name]\n' >&2
    printf "Try 'ports --help' for more information.\n" >&2
    return 2
}

# _dot_ports TOOL [ARGS...]: the body of the shells' `ports`.
# -t TCP listeners (default), -u UDP sockets, -a both. -o orders rows by
# port (default), listening address, or process name; ties fall back to the
# port. -s/--sudo runs the tool through sudo. Short flags combine, as in
# -su or -so name.
_dot_ports() {
    local tool="$1" run=command proto=tcp order=port arg flag i tab
    shift
    while [ $# -gt 0 ]; do
        arg=$1
        shift
        case $arg in
            --sudo) run=sudo; continue ;;
            --help) _dot_ports_help; return 0 ;;
            --order=*) order=${arg#--order=}; continue ;;
            -?*) ;;
            *) _dot_ports_usage; return ;;
        esac
        i=1
        while [ "$i" -lt "${#arg}" ]; do
            flag=${arg:$i:1}
            i=$((i + 1))
            case $flag in
                s) run=sudo ;;
                h) _dot_ports_help; return 0 ;;
                t) proto=tcp ;;
                u) proto=udp ;;
                a) proto=all ;;
                o)
                    # The value is the rest of this argument or the next one.
                    if [ "$i" -lt "${#arg}" ]; then
                        order=${arg:$i}
                    elif [ $# -gt 0 ]; then
                        order=$1
                        shift
                    else
                        _dot_ports_usage; return
                    fi
                    break
                    ;;
                *) _dot_ports_usage; return ;;
            esac
        done
    done

    # Sort keys go in the positional parameters, now that the options are
    # consumed: an unquoted variable would not split into words under Zsh.
    case $order in
        port) set -- -k3,3n -k1,1 -k2,2 ;;
        addr|address) set -- -k2,2 -k3,3n ;;
        name|command) set -- -k5,5 -k3,3n ;;
        *) _dot_ports_usage; return ;;
    esac
    case $tool in
        lsof|ss|netstat) ;;
        *) printf 'ports: unsupported tool: %s\n' "$tool" >&2; return 1 ;;
    esac

    tab=$(printf '\t')
    {
        case $proto in (tcp|all) _dot_ports_run "$run" "$tool" tcp;; esac
        case $proto in (udp|all) _dot_ports_run "$run" "$tool" udp;; esac
    } | awk '!seen[$0]++' | LC_ALL=C sort -t "$tab" "$@" | _dot_ports_table
}

# _dot_ports_run RUNNER TOOL PROTO: one tool invocation, parsed to records.
_dot_ports_run() {
    case $2:$3 in
        lsof:tcp) "$1" lsof +c 0 -nP -iTCP -sTCP:LISTEN -FpcLPn | _dot_ports_lsof ;;
        lsof:udp) "$1" lsof +c 0 -nP -iUDP -FpcLPn | _dot_ports_lsof ;;
        ss:tcp) "$1" ss -ltnp | _dot_ports_ss tcp ;;
        ss:udp) "$1" ss -lunp | _dot_ports_ss udp ;;
        netstat:tcp) "$1" netstat -ltnp | _dot_ports_netstat tcp ;;
        netstat:udp) "$1" netstat -lunp | _dot_ports_netstat udp ;;
    esac
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

# Render sorted tab-separated PARENT, CHILD, DETAIL... records as a tree: each
# parent, then its children indented below it. Columns align across the whole
# tree, not only within one parent. "-" cells are left blank, a column blank
# in every row is dropped, and a "-" child marks a parent with no children.
# Usage: _dot_tsv_tree [color [N]]. With "color", parents are bold, and a
# trailing " (...)" on a parent and every column from N on are dim, counting
# the child as column 1. Padding is measured before the escapes are added.
_dot_tsv_tree() {
    local color=0
    [ "${1:-}" = color ] && color=1
    awk -F '\t' -v color="$color" -v dimfrom="${2:-0}" '
        BEGIN {
            bold=color ? "\033[1m" : ""; dim=color ? "\033[2m" : ""
            reset=color ? "\033[0m" : ""
        }
        {
            parent[++count]=$1; child[count]=$2
            if ($2 != "-" && length($2) > width[1]) width[1]=length($2)
            for (i = 3; i <= NF; i++) {
                cell[count, i - 1]=$i
                if ($i != "-" && length($i) > width[i - 1]) width[i - 1]=length($i)
            }
            if (NF - 1 > cols) cols=NF - 1
        }
        END {
            for (r = 1; r <= count; r++) {
                if (r == 1 || parent[r] != parent[r - 1]) {
                    at=index(parent[r], " (")
                    if (at) print bold substr(parent[r], 1, at - 1) reset dim substr(parent[r], at) reset
                    else print bold parent[r] reset
                }
                if (child[r] == "-") { print "    " dim "(none)" reset; continue }
                last=1
                for (i = 2; i <= cols; i++) if (width[i] > 0 && cell[r, i] != "-" && cell[r, i] != "") last=i
                line=(last == 1) ? child[r] : sprintf("%-*s", width[1], child[r])
                for (i = 2; i <= last; i++) if (width[i] > 0) {
                    value=cell[r, i] == "-" ? "" : cell[r, i]
                    if (i < last) value=sprintf("%-*s", width[i], value)
                    line=line "  " (i >= dimfrom ? dim value reset : value)
                }
                print "    " line
            }
        }
    '
}

# Show each Docker network as a tree of its running containers, with their
# address on that network and the ports they publish or expose. Usage:
# dnets [network...]. Colored only on a terminal without NO_COLOR, so piped
# output stays plain text.
dnets() {
    local color=
    [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && color=color
    command_exist docker || { error "dnets: docker not installed"; return 1; }
    {
        docker ps --format 'P\t{{.Names}}\t{{.Ports}}'
        if [ "$#" -gt 0 ]; then printf '%s\n' "$@"; else docker network ls -q; fi |
            xargs docker network inspect --format '{{$n := .Name}}{{$d := .Driver}}{{range .Containers}}N{{"\t"}}{{$n}}{{"\t"}}{{$d}}{{"\t"}}{{.Name}}{{"\t"}}{{.IPv4Address}}{{"\n"}}{{else}}N{{"\t"}}{{$n}}{{"\t"}}{{$d}}{{"\t-\t-\n"}}{{end}}'
    } | awk -F '\t' '
        $1 == "P" { ports[$2]=$3; next }
        $1 == "N" {
            port=($4 in ports && ports[$4] != "") ? ports[$4] : "-"
            printf "%s (%s)\t%s\t%s\t%s\n", $2, $3, $4, ($5 == "" ? "-" : $5), port
        }
    ' | sort | _dot_tsv_tree "$color" 3
}

# Show each running container as a tree of the networks it joins, with its
# addresses and aliases there. Usage: dcnets [container...]. Colored like dnets.
dcnets() {
    local ids color=
    [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && color=color
    command_exist docker || { error "dcnets: docker not installed"; return 1; }
    if [ "$#" -gt 0 ]; then ids=$(printf '%s\n' "$@"); else ids=$(docker ps -q) || return 1; fi
    [ -n "$ids" ] || { info "dcnets: no running containers"; return 0; }
    printf '%s\n' "$ids" |
        xargs docker inspect --format '{{$c := slice .Name 1}}{{range $k, $v := .NetworkSettings.Networks}}{{$c}}{{"\t"}}{{$k}}{{"\t"}}{{or $v.IPAddress "-"}}{{"\t"}}{{or $v.GlobalIPv6Address "-"}}{{"\t"}}{{if $v.Aliases}}aliases: {{join $v.Aliases ","}}{{else}}-{{end}}{{"\n"}}{{end}}' |
        awk -F '\t' -v OFS='\t' '
            # Docker 25+ stores addresses as netip.Addr, whose unset value
            # prints as "invalid IP" instead of an empty string. Compose also
            # repeats the container name among the aliases.
            NF {
                for (i = 3; i <= 4; i++) if ($i == "invalid IP") $i="-"
                if ($5 != "-") {
                    n=split(substr($5, 10), alias, ","); list=""; split("", seen)
                    for (a = 1; a <= n; a++)
                        if (!(alias[a] in seen)) { seen[alias[a]]=1; list=list (list == "" ? "" : ",") alias[a] }
                    $5="aliases: " list
                }
                print
            }
        ' | sort | _dot_tsv_tree "$color" 4
}

# Show each Docker volume as a tree of the containers that mount it, stopped
# ones included, with the mount point and mode. A state column appears only
# for containers that are not running. Unused anonymous volumes are counted
# on stderr instead of listed. Usage: dvols [volume...]. Colored like dnets.
dvols() {
    local ids color=
    [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && color=color
    command_exist docker || { error "dvols: docker not installed"; return 1; }
    ids=$(docker ps -aq) || return 1
    {
        docker volume ls --format 'V\t{{.Name}}\t{{.Driver}}'
        [ -z "$ids" ] || printf '%s\n' "$ids" |
            xargs docker inspect --format '{{$c := slice .Name 1}}{{$s := .State.Status}}{{range .Mounts}}{{if eq .Type "volume"}}M{{"\t"}}{{.Name}}{{"\t"}}{{$c}}{{"\t"}}{{.Destination}}{{"\t"}}{{if .RW}}rw{{else}}ro{{end}}{{"\t"}}{{$s}}{{"\n"}}{{end}}{{end}}'
    } | awk -F '\t' -v want="$*" '
        BEGIN { n=split(want, w, " "); for (i = 1; i <= n; i++) keep[w[i]]=1 }
        n && !($2 in keep) { next }
        $1 == "V" { driver[$2]=$3; order[++count]=$2; next }
        $1 == "M" {
            used[$2]=1
            printf "%s (%s)\t%s\t%s\t%s\t%s\n", $2, ($2 in driver ? driver[$2] : "?"), $3, $4, $5, ($6 == "running" ? "-" : $6)
        }
        END {
            for (i = 1; i <= count; i++) {
                name=order[i]
                if (name in used) continue
                # Unused anonymous volumes are 64 hex digits each and pile up;
                # count them instead, unless they were asked for by name.
                if (!n && length(name) == 64 && name !~ /[^0-9a-f]/) { hidden++; continue }
                printf "%s (%s)\t-\n", name, driver[name]
            }
            if (hidden) printf "dvols: %d unused anonymous volumes hidden; docker volume prune removes them\n", hidden > "/dev/stderr"
        }
    ' | sort | _dot_tsv_tree "$color" 3
}

# Show each container, stopped ones included, as a tree of its mounts: mount
# point, source (volume name or host path), type, mode and bind propagation.
# Usage: dcvols [container...]. Colored like dnets.
dcvols() {
    local ids color=
    [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && color=color
    command_exist docker || { error "dcvols: docker not installed"; return 1; }
    if [ "$#" -gt 0 ]; then ids=$(printf '%s\n' "$@"); else ids=$(docker ps -aq) || return 1; fi
    [ -n "$ids" ] || { info "dcvols: no containers"; return 0; }
    printf '%s\n' "$ids" |
        xargs docker inspect --format '{{$c := slice .Name 1}}{{if ne .State.Status "running"}}{{$c = printf "%s (%s)" $c .State.Status}}{{end}}{{range .Mounts}}{{$c}}{{"\t"}}{{.Destination}}{{"\t"}}{{if eq .Type "volume"}}{{.Name}}{{else}}{{.Source}}{{end}}{{"\t"}}{{.Type}}{{"\t"}}{{if .RW}}rw{{else}}ro{{end}}{{"\t"}}{{or .Propagation "-"}}{{"\n"}}{{else}}{{$c}}{{"\t-\n"}}{{end}}' |
        sed '/^$/d' | sort | _dot_tsv_tree "$color" 4
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
# Defined on Linux only, so on other platforms the command does not exist
# rather than failing when run, and dgscmds does not list it.
case $OSTYPE in
    linux*) ;;
    *) unset -f sudo_nopasswd;;
esac

_dot_killport_usage() {
    printf 'usage: killport [-s] [-t|-u|-a] [-y] [-9] PORT\n' >&2
    printf "Try 'killport --help' for more information.\n" >&2
    return 2
}

_dot_killport_help() {
    cat <<'HELP'
Usage: killport [OPTION]... PORT
Show the processes listening on PORT, ask for confirmation, then send
them SIGTERM. Uses the same tool and table as ports.

  -t              TCP listeners (default)
  -u              UDP sockets
  -a              both TCP and UDP
  -s, --sudo      look up and signal through sudo: needed for processes
                  owned by other users, whose PID is otherwise unknown
  -y              do not ask for confirmation
  -9              send SIGKILL instead of SIGTERM
  -h, --help      show this help and exit

Short options combine: -s9, -sy.

Examples:
  killport 3000      stop the TCP listener on port 3000, after asking
  killport -u 5353   stop the UDP socket bound to port 5353
  killport -sy9 80   SIGKILL whoever owns port 80, through sudo, no prompt
HELP
}

# _dot_killport TOOL [ARGS...]: the body of the shells' `killport`, which
# reuses the ports parsers to find the listeners and their PIDs.
_dot_killport() {
    local tool="$1" run=command proto=tcp yes= signal=TERM port= arg flag i
    local records pids answer
    shift
    while [ $# -gt 0 ]; do
        arg=$1
        shift
        case $arg in
            --sudo) run=sudo; continue ;;
            --help) _dot_killport_help; return 0 ;;
            -?*) ;;
            *)
                [ -z "$port" ] || { _dot_killport_usage; return; }
                port=$arg
                continue
                ;;
        esac
        i=1
        while [ "$i" -lt "${#arg}" ]; do
            flag=${arg:$i:1}
            i=$((i + 1))
            case $flag in
                s) run=sudo ;;
                h) _dot_killport_help; return 0 ;;
                t) proto=tcp ;;
                u) proto=udp ;;
                a) proto=all ;;
                y) yes=1 ;;
                9) signal=KILL ;;
                *) _dot_killport_usage; return ;;
            esac
        done
    done
    case $port in
        ''|*[!0-9]*) _dot_killport_usage; return ;;
    esac

    records=$(
        {
            case $proto in (tcp|all) _dot_ports_run "$run" "$tool" tcp;; esac
            case $proto in (udp|all) _dot_ports_run "$run" "$tool" udp;; esac
        } | awk -F '\t' -v port="$port" '$3 == port && !seen[$0]++'
    )
    if [ -z "$records" ]; then
        printf 'killport: nothing is listening on port %s\n' "$port" >&2
        return 1
    fi
    printf '%s\n' "$records" | _dot_ports_table
    pids=$(printf '%s\n' "$records" | awk -F '\t' '$4 != "-" && !seen[$4]++ { print $4 }')
    if [ -z "$pids" ]; then
        printf 'killport: PID unknown; retry with -s\n' >&2
        return 1
    fi
    if [ -z "$yes" ]; then
        printf 'Send SIG%s to PID %s? [y/N] ' "$signal" "$(printf '%s' "$pids" | tr '\n' ' ')"
        read -r answer || return 1
        case $answer in
            y|Y|yes|YES) ;;
            *) return 1 ;;
        esac
    fi
    # xargs needs an executable, so `command` cannot be the runner here.
    if [ "$run" = sudo ]; then
        printf '%s\n' "$pids" | xargs sudo kill -s "$signal"
    else
        printf '%s\n' "$pids" | xargs kill -s "$signal"
    fi
}

# Print "NAME VALUE" lines as an aligned two-column table.
_dot_kv_table() {
    awk '
        { key[NR] = $1; sub(/^[^ ]+ /, ""); value[NR] = $0
          if (length(key[NR]) > width) width = length(key[NR]) }
        END { for (row = 1; row <= NR; row++) printf "%-" width "s  %s\n", key[row], value[row] }
    '
}

# Bytes, from stdin, as a short human-readable size.
_DOT_AWK_HUMAN='
function human(bytes,    unit) {
    unit = 1
    while (bytes >= 1024 && unit < 6) { bytes /= 1024; unit++ }
    return sprintf(unit == 1 ? "%d%s" : "%.1f%s", bytes, substr("BKMGTP", unit, 1))
}'

# One screen of host facts: OS, kernel, CPU, memory, root disk, uptime and
# load. macOS reads sysctl and vm_stat; Linux reads /proc and os-release.
sysinfo() {
    local os cpu cores mem_total mem_used boot now uptime load
    case $OSTYPE in
        darwin*)
            os="$(sw_vers -productName) $(sw_vers -productVersion)"
            cpu=$(sysctl -n machdep.cpu.brand_string 2>/dev/null)
            cores=$(sysctl -n hw.ncpu)
            mem_total=$(sysctl -n hw.memsize)
            # Used = active + wired + compressed pages, as Activity Monitor.
            mem_used=$(vm_stat | awk -v page="$(sysctl -n hw.pagesize)" '
                /^Pages active/ || /^Pages wired down/ || /^Pages occupied by compressor/ {
                    gsub(/\./, "", $NF); used += $NF }
                END { printf "%.0f", used * page }')
            boot=$(sysctl -n kern.boottime | sed 's/.*sec = \([0-9]*\).*/\1/')
            now=$(date +%s)
            uptime=$((now - boot))
            load=$(sysctl -n vm.loadavg | awk '{ print $2, $3, $4 }')
            ;;
        linux*)
            os=$(. /etc/os-release 2>/dev/null && printf '%s' "${PRETTY_NAME:-$NAME}")
            cpu=$(awk -F ': *' '/^(model name|Hardware|cpu model)/ { print $2; exit }' /proc/cpuinfo)
            cores=$(getconf _NPROCESSORS_ONLN)
            mem_total=$(awk '/^MemTotal:/ { printf "%.0f", $2 * 1024 }' /proc/meminfo)
            mem_used=$(awk '/^MemTotal:/ { t = $2 } /^MemAvailable:/ { a = $2 }
                END { printf "%.0f", (t - a) * 1024 }' /proc/meminfo)
            uptime=$(awk '{ printf "%d", $1 }' /proc/uptime)
            load=$(awk '{ print $1, $2, $3 }' /proc/loadavg)
            ;;
        *) error "sysinfo: unsupported platform: $OSTYPE"; return 1 ;;
    esac

    {
        printf 'Host %s\n' "$(uname -n)"
        printf 'OS %s\n' "${os:--}"
        printf 'Kernel %s\n' "$(uname -sr)"
        printf 'Arch %s\n' "$(uname -m)"
        printf 'CPU %s (%s cores)\n' "${cpu:--}" "$cores"
        awk -v used="$mem_used" -v total="$mem_total" "$_DOT_AWK_HUMAN"'
            BEGIN { printf "Memory %s / %s (%d%%)\n", human(used), human(total), used * 100 / total }'
        df -Pk / | awk "$_DOT_AWK_HUMAN"'
            NR == 2 { printf "Disk / %s / %s (%s)\n", human($3 * 1024), human($2 * 1024), $5 }'
        awk -v s="$uptime" 'BEGIN {
            d = int(s / 86400); h = int(s % 86400 / 3600); m = int(s % 3600 / 60)
            printf "Uptime %s%dh %dm\n", d ? d "d " : "", h, m }'
        printf 'Load %s\n' "$load"
    } | _dot_kv_table
}

# Disk usage of real filesystems only: device-backed, network and FUSE
# mounts. Pseudo filesystems (tmpfs, overlay, proc), snap loop devices and
# macOS's sealed system volumes under /System/Volumes are left out.
# Usage: dfh [df options], for example dfh -i.
dfh() {
    df -hP "$@" | awk '
        NR == 1 { next }
        {
            mount = $6
            for (field = 7; field <= NF; field++) mount = mount " " $field
        }
        $1 !~ /^\/dev\// && $1 !~ /:/ && $1 !~ /^\/\// && $1 !~ /^map / { next }
        $1 ~ /^\/dev\/loop/ { next }
        mount ~ /^\/System\/Volumes\// && mount != "/System/Volumes/Data" { next }
        { rows[++count] = $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" mount }
        END {
            split("FILESYSTEM SIZE USED AVAIL USE% MOUNT", head, " ")
            for (column = 1; column <= 6; column++) width[column] = length(head[column])
            for (row = 1; row <= count; row++) {
                split(rows[row], field, "\t")
                for (column = 1; column <= 6; column++)
                    if (length(field[column]) > width[column]) width[column] = length(field[column])
            }
            for (column = 1; column < 6; column++) format[column] = "%-" width[column] "s  "
            format[6] = "%s\n"
            for (column = 1; column <= 6; column++) printf format[column], head[column]
            for (row = 1; row <= count; row++) {
                split(rows[row], field, "\t")
                for (column = 1; column <= 6; column++) printf format[column], field[column]
            }
        }
    '
}

# systemd shortcuts. Defined on Linux only, below.
svc() {
    local scope= action unit
    if [ "${1:-}" = --user ]; then
        scope=--user
        shift
    fi
    action=${1:-}
    [ $# -eq 0 ] || shift
    case $action in
        ''|ls|list)
            systemctl $scope list-units --type=service --state=running --no-pager ;;
        all)
            systemctl $scope list-units --type=service --all --no-pager ;;
        failed)
            systemctl $scope list-units --type=service --failed --no-pager ;;
        logs|log)
            [ $# -gt 0 ] || { printf 'usage: svc logs UNIT [journalctl options]\n' >&2; return 2; }
            unit=$1
            shift
            if [ -n "$scope" ]; then
                journalctl --user-unit "$unit" -n 100 -f "$@"
            else
                journalctl -u "$unit" -n 100 -f "$@"
            fi
            ;;
        status|cat|show|is-active|is-enabled)
            [ $# -gt 0 ] || { printf 'usage: svc %s UNIT...\n' "$action" >&2; return 2; }
            systemctl $scope "$action" --no-pager "$@" ;;
        start|stop|restart|reload|enable|disable|mask|unmask)
            [ $# -gt 0 ] || { printf 'usage: svc %s UNIT...\n' "$action" >&2; return 2; }
            # System units change through sudo unless already root.
            if [ -n "$scope" ] || [ "$(id -u)" -eq 0 ]; then
                systemctl $scope "$action" "$@"
            else
                sudo systemctl "$action" "$@"
            fi
            ;;
        -h|--help|help)
            cat <<'HELP'
Usage: svc [--user] [ACTION] [UNIT]...
Shortcuts for systemctl and journalctl. --user acts on the user manager.

  svc                     running services (also: svc ls)
  svc all                 all loaded services
  svc failed              failed services
  svc status UNIT...      status, without a pager (also cat, show,
                          is-active, is-enabled)
  svc start UNIT...       start, stop, restart, reload, enable, disable,
                          mask or unmask; system units run through sudo
                          unless you are root
  svc logs UNIT [OPT]...  last 100 journal lines, then follow; extra
                          options go to journalctl

Examples:
  svc failed                    what broke since boot
  svc restart nginx             restart a system unit through sudo
  svc logs nginx --since today  today's journal for nginx, then follow
  svc --user status syncthing   a unit of the user manager
HELP
            ;;
        *) printf "svc: unknown action: %s\nTry 'svc --help' for more information.\n" "$action" >&2; return 2 ;;
    esac
}
case $OSTYPE in
    linux*) ;;
    *) unset -f svc;;
esac

# --- Network ---------------------------------------------------------------

# Public IPv4 and IPv6 of this host. Shorthand for `ips public`.
myip() { ips public; }

# --- Processes -------------------------------------------------------------

# Print ps rows as a table: the first NF_FIXED fields as given, then the
# command, cut to the terminal width so one process stays on one line.
# Usage: _dot_ps_table HEADER FORMAT; FORMAT has one %s per header word.
# A field named RSS is shown as a human-readable size.
_dot_ps_table() {
    awk -v header="$1" -v format="$2" -v cols="${COLUMNS:-160}" "$_DOT_AWK_HUMAN"'
        BEGIN {
            fixed=split(header, h, " ") - 1
            line=sprintf(format, h[1], h[2], h[3], h[4], h[5], h[6])
            printf "%s", line; width=cols - (length(line) - length(h[fixed + 1]) - 1)
        }
        {
            cmd=$0
            for (i = 1; i <= fixed; i++) {
                sub(/^ *[^ ]+ +/, "", cmd)
                f[i]=(h[i] == "RSS") ? human($i * 1024) : $i
            }
            if (width > 20 && length(cmd) > width) cmd=substr(cmd, 1, width - 3) "..."
            f[fixed + 1]=cmd
            printf format, f[1], f[2], f[3], f[4], f[5], f[6]
        }
    '
}

# Find processes whose command line contains PATTERN, case-insensitively,
# leaving out the search itself. Usage: psg PATTERN. Returns 1 on no match.
psg() {
    local rows
    case ${1:-} in
        ''|-h|--help)
            printf 'Usage: psg PATTERN\nProcesses whose command line contains PATTERN, ignoring case.\n\nExamples:\n  psg node\n  psg "python manage.py"\n'
            [ $# -gt 0 ]; return ;;
    esac
    rows=$(ps axww -o pid=,user=,%cpu=,%mem=,etime=,command= | awk -v pat="$*" '
        BEGIN { pat=tolower(pat) }
        {
            cmd=$0
            for (i = 1; i <= 5; i++) sub(/^ *[^ ]+ +/, "", cmd)
            if (cmd ~ /^(ps axww|awk -v pat)/) next
            if (index(tolower(cmd), pat)) print
        }
    ')
    [ -n "$rows" ] || return 1
    printf '%s\n' "$rows" |
        _dot_ps_table 'PID USER %CPU %MEM ELAPSED COMMAND' '%7s  %-10s %5s %5s  %11s  %s\n'
}

# The N processes (default 10) using the most resident memory.
# Usage: topmem [N].
topmem() {
    local n=${1:-10}
    case $n in ''|*[!0-9]*) printf 'usage: topmem [N]\n' >&2; return 2 ;; esac
    ps axww -o pid=,user=,%mem=,rss=,command= | sort -k4 -nr | head -n "$n" |
        _dot_ps_table 'PID USER %MEM RSS COMMAND' '%7s  %-10s %5s  %7s  %s\n'
}

# --- Docker ----------------------------------------------------------------

# Resolve NAME to one running container: an exact name or ID first, then a
# unique substring of a running container's name. Prints the name.
_dot_docker_pick() {
    local matches count
    if docker inspect --type container --format '{{slice .Name 1}}' "$1" 2>/dev/null; then
        return 0
    fi
    matches=$(docker ps --format '{{.Names}}' | grep -F -- "$1")
    count=$(printf '%s' "$matches" | grep -c '')
    case $count in
        0) error "no running container matches: $1"; return 1 ;;
        1) printf '%s\n' "$matches" ;;
        *) error "several containers match $1:"; printf '  %s\n' $matches >&2; return 1 ;;
    esac
}

# Open a shell in a running container: bash when the image has it, else sh.
# Usage: dsh NAME [COMMAND...]. NAME may be a unique part of the name; with
# COMMAND, run that instead of a shell.
dsh() {
    local name
    case ${1:-} in
        ''|-h|--help)
            cat <<'HELP'
Usage: dsh NAME [COMMAND...]
Open bash, or sh when the image has no bash, in a running container. NAME
is an exact name or ID, or a part of one running container's name.

Examples:
  dsh web                 shell in the only container whose name has "web"
  dsh db psql -U postgres run psql instead of a shell
HELP
            [ $# -gt 0 ]; return ;;
    esac
    command_exist docker || { error "dsh: docker not installed"; return 1; }
    name=$(_dot_docker_pick "$1") || return 1
    shift
    if [ $# -gt 0 ]; then
        docker exec -it "$name" "$@"
    else
        docker exec -it "$name" sh -c 'command -v bash >/dev/null 2>&1 && exec bash || exec sh'
    fi
}

# Running containers with their address on each network and their ports.
# Usage: dips [container...].
dips() {
    local ids
    command_exist docker || { error "dips: docker not installed"; return 1; }
    if [ $# -gt 0 ]; then ids=$(printf '%s\n' "$@"); else ids=$(docker ps -q) || return 1; fi
    [ -n "$ids" ] || { info "dips: no running containers"; return 0; }
    printf '%s\n' "$ids" |
        xargs docker inspect --format '{{$c := slice .Name 1}}{{$p := ""}}{{range $k, $v := .NetworkSettings.Ports}}{{if $v}}{{range $v}}{{$p = printf "%s%s:%s->%s," $p .HostIp .HostPort $k}}{{end}}{{else}}{{$p = printf "%s%s," $p $k}}{{end}}{{end}}{{range $k, $v := .NetworkSettings.Networks}}{{$c}}{{"\t"}}{{$k}}{{"\t"}}{{or $v.IPAddress "-"}}{{"\t"}}{{or $p "-"}}{{"\n"}}{{end}}' |
        awk -F '\t' '
            NF {
                if ($3 == "invalid IP" || $3 == "") $3="-"
                sub(/,$/, "", $4); gsub(/,/, ", ", $4)
                row[++n]=$0; name[n]=$1; net[n]=$2; ip[n]=$3; port[n]=$4
                if (length($1) > w1) w1=length($1)
                if (length($2) > w2) w2=length($2)
                if (length($3) > w3) w3=length($3)
            }
            END {
                if (w1 < 9) w1=9; if (w2 < 7) w2=7; if (w3 < 4) w3=4
                printf "%-*s  %-*s  %-*s  %s\n", w1, "CONTAINER", w2, "NETWORK", w3, "IPv4", "PORTS"
                for (i = 1; i <= n; i++)
                    printf "%-*s  %-*s  %-*s  %s\n", w1, name[i], w2, net[i], w3, ip[i], port[i]
            }
        ' | { IFS= read -r head; printf '%s\n' "$head"; sort; }
}

# Show what Docker can reclaim, ask, then remove stopped containers,
# dangling images, unused networks and build cache. Volumes hold data, so
# unused anonymous volumes are removed only with -v.
# Usage: dclean [-v] [-y].
dclean() {
    local volumes= yes= arg answer
    command_exist docker || { error "dclean: docker not installed"; return 1; }
    for arg in "$@"; do
        case $arg in
            -v) volumes=1 ;;
            -y) yes=1 ;;
            -vy|-yv) volumes=1; yes=1 ;;
            -h|--help)
                cat <<'HELP'
Usage: dclean [-v] [-y]
List stopped containers and dangling images, show `docker system df`, ask,
then prune containers, dangling images, unused networks and build cache.

  -v  also remove unused anonymous volumes (they may hold data)
  -y  do not ask

Examples:
  dclean        review, then confirm
  dclean -vy    also drop unused volumes, without asking
HELP
                return 0 ;;
            *) printf 'usage: dclean [-v] [-y]\n' >&2; return 2 ;;
        esac
    done
    printf 'Stopped containers:\n'
    docker ps -a --filter status=exited --filter status=created --filter status=dead \
        --format '  {{.Names}}\t{{.Status}}\t{{.Image}}'
    printf 'Dangling images:\n'
    docker images --filter dangling=true --format '  {{.ID}}\t{{.Size}}\t{{.CreatedSince}}'
    if [ -n "$volumes" ]; then
        printf 'Unused volumes:\n'
        docker volume ls --filter dangling=true --format '  {{.Name}}'
    fi
    printf '\n'
    docker system df
    if [ -z "$yes" ]; then
        printf '\nRemove these%s? [y/N] ' "${volumes:+ (including volumes)}"
        read -r answer
        case $answer in [yY]|[yY][eE][sS]) ;; *) return 1 ;; esac
    fi
    docker container prune -f &&
        docker image prune -f &&
        docker network prune -f &&
        docker builder prune -f &&
        { [ -z "$volumes" ] || docker volume prune -f; }
}

# --- Files -----------------------------------------------------------------

# Create a directory, with parents, and change into it. Usage: mkcd DIR.
mkcd() {
    [ $# -eq 1 ] || { printf 'usage: mkcd DIR\n' >&2; return 2; }
    mkdir -p -- "$1" && cd -- "$1"
}

# Unpack archives by extension into the current directory.
# Usage: extract FILE...
extract() {
    local file tool rc=0
    case ${1:-} in
        ''|-h|--help)
            cat <<'HELP'
Usage: extract FILE...
Unpack each archive into the current directory, chosen by extension:
tar(.gz|.bz2|.xz|.zst), tgz, zip, jar, 7z, rar, gz, bz2, xz, zst.
Single-file formats keep the compressed original.

Examples:
  extract release.tar.gz
  extract *.zip
HELP
            [ $# -gt 0 ]; return ;;
    esac
    for file in "$@"; do
        [ -f "$file" ] || { error "extract: no such file: $file"; rc=1; continue; }
        case $file in
            *.tar.zst|*.tzst) tool=zstd ;;
            *.tar|*.tar.gz|*.tgz|*.tar.bz2|*.tbz|*.tbz2|*.tar.xz|*.txz) tool=tar ;;
            *.zip|*.jar) tool=unzip ;;
            *.7z) tool=7z ;;
            *.rar) tool=unrar ;;
            *.gz) tool=gunzip ;;
            *.bz2) tool=bunzip2 ;;
            *.xz) tool=unxz ;;
            *.zst) tool=zstd ;;
            *) error "extract: unknown archive type: $file"; rc=1; continue ;;
        esac
        command_exist "$tool" || { error "extract: $tool not installed"; rc=1; continue; }
        case $file in
            *.tar.zst|*.tzst) zstd -dc -- "$file" | tar -xf - ;;
            *.tar|*.tar.gz|*.tgz|*.tar.bz2|*.tbz|*.tbz2|*.tar.xz|*.txz) tar -xf "$file" ;;
            *.zip|*.jar) unzip -q -- "$file" ;;
            *.7z) 7z x -- "$file" ;;
            *.rar) unrar x -- "$file" ;;
            *.gz) gunzip -k -- "$file" ;;
            *.bz2) bunzip2 -k -- "$file" ;;
            *.xz) unxz -k -- "$file" ;;
            *.zst) zstd -d -- "$file" ;;
        esac || rc=1
    done
    return "$rc"
}

# Copy each FILE or directory to FILE.bak.YYYYMMDD-HHMMSS beside it,
# keeping modes and times. Usage: bak FILE...
bak() {
    local file stamp rc=0
    [ $# -gt 0 ] || { printf 'usage: bak FILE...\n' >&2; return 2; }
    stamp=$(date +%Y%m%d-%H%M%S)
    for file in "$@"; do
        file=${file%/}
        cp -pR -- "$file" "$file.bak.$stamp" && printf '%s\n' "$file.bak.$stamp" || rc=1
    done
    return "$rc"
}

# Serve the current directory over HTTP on every interface, so other hosts
# on the network can reach it. Usage: serve [PORT], default 8000. Ctrl-C stops.
serve() {
    local port=${1:-8000}
    case $port in
        -h|--help)
            cat <<'HELP'
Usage: serve [PORT]
Serve the current directory over HTTP on every interface (default port
8000) and print the URLs. Anyone on the network can read it. Ctrl-C stops.

Examples:
  serve           http://<this host>:8000/
  serve 9000      on port 9000
HELP
            return 0 ;;
        ''|*[!0-9]*) printf 'usage: serve [PORT]\n' >&2; return 2 ;;
    esac
    command_exist python3 || { error "serve: python3 not installed"; return 1; }
    printf 'Serving %s on port %s (all interfaces):\n  http://localhost:%s/\n' "$PWD" "$port" "$port"
    ips local 2>/dev/null | awk -v port="$port" 'NR > 1 && $3 != "-" {
        n=split($3, a, ", "); for (i = 1; i <= n; i++) printf "  http://%s:%s/\n", a[i], port }'
    python3 -m http.server "$port"
}

# List the commands this configuration adds to the interactive shell,
# grouped by purpose: the functions in the table below, then the aliases the
# shell's alias file created. Only what is defined in this shell is shown, so
# a command whose tool is missing (dps or dnets without docker, ports
# without lsof/ss/netstat) does not appear. A platform-specific function is
# defined only on its platform, as sudo_nopasswd and svc are, so the same
# check leaves it out elsewhere. A section with nothing to show is omitted.
# Usage: dgscmds [-l | SECTION...]. By default each section is one line of
# names; -l shows every usage line, and SECTION (case-insensitive, e.g.
# `dgscmds docker`) shows only those sections in full. Add a row here when
# adding a user-facing function.
dgscmds() {
    local name section requires usage description value full=0 only=

    case ${1:-} in
        '') ;;
        -l|--long) full=1 ;;
        -h|--help) printf 'usage: dgscmds [-l | SECTION...]\n'; return 0 ;;
        *) full=1; only=$(printf '%s ' "$@" | tr '[:upper:]' '[:lower:]') ;;
    esac

    {
        # Tab-separated SECTION, NAME, REQUIRED TOOL (- for none), USAGE,
        # DESCRIPTION; the usage column itself contains '|'.
        while IFS=$'\t' read -r section name requires usage description; do
            type "$name" >/dev/null 2>&1 || continue
            [ "$requires" = - ] || command_exist "$requires" || continue
            printf '%s\t%s\t%s\n' "$section" "$usage" "$description"
        done <<'TABLE'
Network	ports	-	ports [-s] [-t|-u|-a] [-o KEY]	listening sockets as a sortable table
Network	killport	-	killport [-s] [-y] [-9] PORT	stop the processes listening on PORT
Network	ips	-	ips [local|public]	local interface addresses, or public IPv4/IPv6
Network	myip	curl	myip	public IPv4 and IPv6 (ips public)
Process	psg	-	psg PATTERN	processes whose command line matches
Process	topmem	-	topmem [N]	top N processes by resident memory
System	sysinfo	-	sysinfo	OS, CPU, memory, disk, uptime and load
System	dfh	-	dfh	disk usage of real filesystems only
System	svc	systemctl	svc [--user] [ACTION] [UNIT]	systemctl and journalctl shortcuts
System	sudo_nopasswd	sudo	sudo_nopasswd [on|off|status]	toggle passwordless sudo for this user
Docker	dnets	docker	dnets [network...]	networks as trees of their containers
Docker	dcnets	docker	dcnets [container...]	running containers as trees of their networks
Docker	dvols	docker	dvols [volume...]	volumes as trees of the containers mounting them
Docker	dcvols	docker	dcvols [container...]	containers as trees of their mounts
Docker	dips	docker	dips [container...]	containers with network, IPv4 and ports
Docker	dsh	docker	dsh NAME [COMMAND...]	shell (bash, else sh) in a running container
Docker	dclean	docker	dclean [-v] [-y]	show and prune unused containers, images, cache
Files	mkcd	-	mkcd DIR	create DIR and cd into it
Files	extract	-	extract FILE...	unpack archives by extension
Files	bak	-	bak FILE...	copy to FILE.bak.<timestamp>
Files	serve	python3	serve [PORT]	share this directory over HTTP (default 8000)
Shell	dgscmds	-	dgscmds	this list
TABLE
        _dot_managed_aliases | while IFS=$'\t' read -r name value; do
            case $name in
                ls|l|ll|la|tree|..|...) section=Files ;;
                g*) section=Git ;;
                d*) section=Docker ;;
                *) section=Replacements ;;
            esac
            [ "${#value}" -le 60 ] || value="${value:0:57}..."
            printf '%s\t%s\t= %s\n' "$section" "$name" "$value"
        done
    } | awk -F '\t' -v full="$full" -v only="$only" '
        BEGIN {
            count = split("Network Process System Files Git Docker Replacements Shell", order, " ")
            n = split(only, w, " "); for (i = 1; i <= n; i++) want[w[i]] = 1
        }
        n && !(tolower($1) in want) { next }
        full { rows[$1] = rows[$1] sprintf("  %-32s %s\n", $2, $3); next }
        { split($2, word, " "); rows[$1] = rows[$1] " " word[1] }
        END {
            for (section = 1; section <= count; section++) {
                if (!(order[section] in rows)) continue
                if (full) printf "%s%s:\n%s", printed++ ? "\n" : "", order[section], rows[order[section]]
                else printf "%-13s%s\n", order[section] ":", rows[order[section]]
            }
            if (!full) print "\ndgscmds -l for usage, dgscmds SECTION for one section, CMD --help for examples"
        }
    '
}

# Print the aliases the shell's alias file created, as NAME<TAB>VALUE.
_dot_managed_aliases() {
    local name value
    if [ -n "${ZSH_VERSION:-}" ]; then
        for name in "${_DOT_ZSH_MANAGED_ALIASES[@]}"; do
            value=${aliases[$name]:-}
            [ -n "$value" ] && printf '%s\t%s\n' "$name" "$value"
        done
    else
        for name in ${_DOT_BASH_MANAGED_ALIASES[@]+"${_DOT_BASH_MANAGED_ALIASES[@]}"}; do
            # BASH_ALIASES is missing from Bash 3.2, which macOS ships, so
            # read the definition back from `alias`: alias NAME='VALUE'.
            value=$(alias -- "$name" 2>/dev/null) || continue
            value=${value#*=\'}
            value=${value%\'}
            [ -n "$value" ] && printf '%s\t%s\n' "$name" "$value"
        done
    fi
    return 0
}
