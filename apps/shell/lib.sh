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
        case $proto in tcp|all) _dot_ports_run "$run" "$tool" tcp;; esac
        case $proto in udp|all) _dot_ports_run "$run" "$tool" udp;; esac
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
