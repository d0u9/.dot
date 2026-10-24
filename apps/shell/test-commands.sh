#!/bin/bash
# Run with bash or zsh: test-commands.sh /absolute/path/to/lib.sh [AWK]
# Uses invented fixtures and stub executables; no private hooks or services.
set -eu
command_test_lib=${1:?Pass the absolute path to apps/shell/lib.sh}
command_test_awk=${2:-$(command -v awk)}
# shellcheck source=lib.sh
source "$command_test_lib"
command_test_dir=$(mktemp -d)
trap 'rm -rf -- "$command_test_dir"' EXIT
export DOT_COMMAND_TEST_AWK=$command_test_awk
mkdir -p "$command_test_dir/bin"
cat > "$command_test_dir/bin/awk" <<'STUB'
#!/bin/bash
exec "$DOT_COMMAND_TEST_AWK" "$@"
STUB
cat > "$command_test_dir/bin/docker" <<'STUB'
#!/bin/bash
case $1 in
    ps)
        case $* in
            *'P\t'*) printf 'P\tweb\t192.0.2.1:8080->80/tcp\n' ;;
            *--format*) printf 'web\nworker\n' ;;
            *) printf 'container-1\n' ;;
        esac ;;
    network)
        case $2 in
            ls) printf 'network-1\n' ;;
            inspect) printf 'N\tapp-net\tbridge\tweb\t192.0.2.2/24\nN\tempty-net\tbridge\t-\t-\n' ;;
            *) exit 2 ;;
        esac ;;
    volume) printf 'V\tapp-data\tlocal\nV\tunused-data\tlocal\n' ;;
    inspect)
        case ${DOT_COMMAND_TEST_VIEW:-} in
            dcnets) printf 'web\tapp-net\t192.0.2.2\tinvalid IP\taliases: web,web,app\nworker\tapp-net\tinvalid IP\t2001:db8::2\t-\n' ;;
            dvols) printf 'M\tapp-data\tweb\t/data\trw\trunning\n' ;;
            dcvols) printf 'web\t/data\tapp-data\tvolume\trw\t-\nworker (exited)\t-\n' ;;
            dips) printf 'web\tapp-net\t192.0.2.2\t192.0.2.1:8080->80/tcp,\nworker\tapp-net\tinvalid IP\t-\n' ;;
            pick) exit 1 ;;
            *) exit 2 ;;
        esac ;;
    *) exit 2 ;;
esac
STUB
chmod +x "$command_test_dir/bin/awk" "$command_test_dir/bin/docker"
PATH=$command_test_dir/bin:$PATH
export PATH
if [ -n "${ZSH_VERSION:-}" ]; then
    rehash
    typeset -ga _DOT_ZSH_MANAGED_ALIASES=()
fi

assert_eq() {
    if [ "$1" != "$2" ]; then
        printf 'FAIL: %s\n' "$3" >&2
        exit 1
    fi
}
contains() {
    printf '%s\n' "$1" | command grep -F -- "$2" >/dev/null || {
        printf 'FAIL: missing %s\n' "$2" >&2
        exit 1
    }
}
absent() {
    if printf '%s\n' "$1" | command grep -F -- "$2" >/dev/null; then
        printf 'FAIL: unexpected %s\n' "$2" >&2
        exit 1
    fi
}

# Every socket backend feeds the same table. Include IPv6, a missing PID,
# duplicate descriptors and program names with blanks.
lsof_rows=$(printf 'p42\ncweb\nLalice\nPTCP\nn192.0.2.1:8080\nn192.0.2.1:8080\np43\ncworker\nLbob\nPTCP\nn[2001:db8::1]:443\n' | _dot_ports_lsof)
contains "$lsof_rows" "$(printf 'tcp\t192.0.2.1\t8080\t42\tweb')"
ss_rows=$(printf 'State Recv-Q Send-Q Local Peer Process\nLISTEN 0 128 [2001:db8::1]:443 [::]:* users:(("worker",pid=43,fd=3))\nLISTEN 0 128 192.0.2.1:8080 0.0.0.0:*\n' | _dot_ports_ss tcp)
contains "$ss_rows" "$(printf 'tcp\t2001:db8::1\t443\t43\tworker\t-')"
contains "$ss_rows" "$(printf 'tcp\t192.0.2.1\t8080\t-\t-\t-')"
netstat_rows=$(printf 'tcp 0 0 192.0.2.1:8080 0.0.0.0:* LISTEN 42/web server\n' | _dot_ports_netstat tcp)
contains "$netstat_rows" 'web server'
netstat_udp_rows=$(printf 'udp6 0 0 :::53 :::* 43/dns\n' | _dot_ports_netstat udp)
contains "$netstat_udp_rows" "$(printf 'udp\t::\t53\t43\tdns\t-')"
_dot_ports_run() { printf '%s\n' "$ss_rows" "$lsof_rows"; }
out=$(_dot_ports ss -a --order=name)
contains "$out" 'PROTO'
contains "$out" '8080'
contains "$out" 'worker'
if _dot_ports ss --order=invalid >/dev/null 2>&1; then exit 1; fi

# Local address discovery: macOS, Linux iproute2 and legacy ifconfig.
ifconfig() {
    cat <<'FIXTURE'
eth0: flags=1
    ether 02:00:00:00:00:01
    inet 192.0.2.1 netmask 0xffffff00
    inet 198.51.100.1 netmask 0xffffff00
    inet6 2001:db8::1 prefixlen 64
    inet6 fe80::1%eth0 prefixlen 64
lo0: flags=1
    inet 127.0.0.1 netmask 0xff000000
    inet6 ::1 prefixlen 128
FIXTURE
}
ip() {
    case $* in
        '-o link show') printf '2: eth0: <UP> mtu 1500 link/ether 02:00:00:00:00:01\n' ;;
        '-o -4 addr show scope global') printf '2: eth0 inet 192.0.2.1/24 scope global eth0\n' ;;
        '-o -6 addr show scope global') printf '2: eth0 inet6 2001:db8::1/64 scope global\n' ;;
        *) return 2 ;;
    esac
}
for command_test_platform in darwin-test linux-test; do
    out=$(OSTYPE=$command_test_platform ips local)
    contains "$out" '02:00:00:00:00:01'
    contains "$out" '192.0.2.1'
    contains "$out" '2001:db8::1'
    absent "$out" '127.0.0.1'
    absent "$out" 'fe80::1'
done
unset -f ip
command_exist() { [ "$1" != ip ] && command -v "$1" >/dev/null 2>&1; }
out=$(OSTYPE=linux-test ips local)
contains "$out" '198.51.100.1'
unset -f command_exist
command_exist() { command -v "$1" >/dev/null 2>&1; }

# Catch scalar/array collisions on actual data, including mount paths with
# blanks. Pseudo and sealed-system filesystems must stay out of the table.
df() {
    cat <<'FIXTURE'
Filesystem Size Used Avail Use% Mounted on
/dev/disk1 100G 40G 60G 40% /
/dev/disk2 200G 50G 150G 25% /Volumes/Example Disk
/dev/disk3 100G 40G 60G 40% /System/Volumes/Preboot
/dev/disk4 100G 40G 60G 40% /System/Volumes/Data
/dev/loop0 1G 1G 0 100% /snap/example
host-a.example.test:/share 100G 10G 90G 10% /mnt/share
tmpfs 1G 0 1G 0% /run
FIXTURE
}
out=$(dfh .)
contains "$out" '/Volumes/Example Disk'
contains "$out" '/System/Volumes/Data'
contains "$out" 'host-a.example.test:/share'
absent "$out" 'Preboot'
absent "$out" '/dev/loop0'
absent "$out" 'tmpfs'

# kern.boottime contains both sec and usec; only sec sets the uptime.
sysctl() {
    case $2 in
        machdep.cpu.brand_string) printf 'Example CPU\n' ;;
        hw.ncpu) printf '4\n' ;;
        hw.memsize) printf '8388608\n' ;;
        hw.pagesize) printf '4096\n' ;;
        kern.boottime) printf '{ sec = 1700000000, usec = 123456 }\n' ;;
        vm.loadavg) printf '{ 1.0 2.0 3.0 }\n' ;;
        *) return 2 ;;
    esac
}
sw_vers() { printf 'ExampleOS\n'; }
vm_stat() { printf 'Pages active: 100.\nPages wired down: 100.\nPages occupied by compressor: 56.\n'; }
date() {
    case ${1:-} in
        +%s) printf '1700003660\n' ;;
        *) command date "$@" ;;
    esac
}
uname() { printf 'host-a\n'; }
out=$(OSTYPE=darwin-test sysinfo)
contains "$out" '1h 1m'
contains "$out" '1.0M / 8.0M (12%)'
contains "$out" '1.0 2.0 3.0'

# Process commands use a shared formatter but different field counts.
ps() {
    case $* in
        *rss*) printf ' 42 alice 5.0 2048 example-worker\n 43 bob 2.0 1024 example-server\n' ;;
        *) printf '%s\n' ' 42 alice 1.0 5.0 01:02 Example-Worker --flag' ' 43 bob 0.0 2.0 02:03 unrelated C:\new\test [literal]' ;;
    esac
}
out=$(psg example-worker)
contains "$out" 'Example-Worker --flag'
absent "$out" 'unrelated'
if psg no-match >/dev/null; then exit 1; fi
out=$(psg 'C:\new\test')
contains "$out" 'C:\new\test'
out=$(psg '[literal]')
contains "$out" '[literal]'
out=$(topmem 1)
contains "$out" '2.0M'
absent "$out" 'example-server'

# Docker views run only against the stub, including absent IPv4 and repeated
# aliases. Never query the host daemon or run prune/exec in this check.
export DOT_COMMAND_TEST_VIEW=dcnets
out=$(dcnets)
contains "$out" 'aliases: web,app'
contains "$out" '2001:db8::2'
absent "$out" 'invalid IP'
out=$(dnets)
contains "$out" 'app-net (bridge)'
contains "$out" '(none)'
export DOT_COMMAND_TEST_VIEW=dvols
out=$(dvols app-data)
contains "$out" 'app-data (local)'
absent "$out" 'unused-data'
export DOT_COMMAND_TEST_VIEW=dcvols
out=$(dcvols)
contains "$out" 'worker (exited)'
contains "$out" '/data'
export DOT_COMMAND_TEST_VIEW=dips
out=$(dips)
contains "$out" 'CONTAINER'
contains "$out" '192.0.2.2'
absent "$out" 'invalid IP'
export DOT_COMMAND_TEST_VIEW=pick
assert_eq "$(_dot_docker_pick web)" web 'unique container substring'
if _dot_docker_pick w >/dev/null 2>&1; then exit 1; fi
if _dot_docker_pick no-match >/dev/null 2>&1; then exit 1; fi

# File helpers operate only inside the fixture directory, including names
# with blanks and relative symlinks that must survive being moved.
(
    cd "$command_test_dir"
    mkdir -p files
    cd files
    printf 'example\n' > 'source file'
    lns -p 'source file' links/link
    assert_eq "$(readlink links/link)" '../source file' 'relative symlink'
    lnmv -p links/link moved/deeper/link
    assert_eq "$(readlink moved/deeper/link)" '../../source file' 'moved relative symlink'
    [ ! -L links/link ]
    cmp 'source file' moved/deeper/link
    touch -t 200101020304.06 reference
    cptime reference 'source file'
    [ ! reference -nt 'source file' ] && [ ! reference -ot 'source file' ]
    out=$(bak 'source file')
    cmp 'source file' "$out"
    mkcd new/dir
    assert_eq "${PWD##*/}" dir 'create and enter directory'
)

# Print a URL for each IPv4 address; do not start an actual HTTP server.
python3() { [ "$*" = '-m http.server 9000' ]; }
out=$(OSTYPE=darwin-test serve 9000)
contains "$out" 'http://192.0.2.1:9000/'
contains "$out" 'http://198.51.100.1:9000/'
absent "$out" '192.0.2.1,:9000'

# The command catalogue must keep one described row per shortcut, with
# case-insensitive section selection and the full usage on request.
out=$(dgscmds)
contains "$out" '| Description'
contains "$out" 'dfh'
out=$(dgscmds GiT)
contains "$out" 'gps [--dry-run] [REMOTE]'
absent "$out" '| Files'
out=$(dgscmds -l)
contains "$out" 'mkcd DIR'
contains "$out" 'dfh'
printf 'Command checks passed (%s)\n' "${ZSH_VERSION:-Bash $BASH_VERSION}"
