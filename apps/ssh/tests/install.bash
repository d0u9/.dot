#!/bin/bash
set -euo pipefail
cd -- "$(dirname -- "$0")/../../.."
test_dir=$(mktemp -d)
trap 'rm -rf -- "$test_dir"' EXIT
export HOME="$test_dir/home" XDG_STATE_HOME="$test_dir/state"
mkdir -p "$HOME/.ssh/config.d"
printf 'Host *\n    ConnectTimeout 77\n' > "$test_dir/inactive-fragment"
cp "$test_dir/inactive-fragment" "$HOME/.ssh/config.d/90-existing.conf"

install_ssh() { bash install.sh ssh > "$test_dir/install.log"; }
uninstall_ssh() { bash install.sh -r ssh > "$test_dir/uninstall.log"; }
effective_config() {
    # OpenSSH expands ~ using the account home, not the isolated HOME above.
    sed "s|~/.ssh/config.d/|$HOME/.ssh/config.d/|g" "$HOME/.ssh/config" > "$test_dir/effective.conf"
    ssh -G -F "$test_dir/effective.conf" host-a 2>/dev/null
}

# A new host gets an entry point; repeated installs leave it unchanged.
install_ssh
[ -L "$HOME/.ssh/config.d/00-dot.conf" ]
printf '%s\n' 'Include ~/.ssh/config.d/00-dot.conf' > "$test_dir/entry"
cmp "$test_dir/entry" "$HOME/.ssh/config"
[ "$(ls -l "$HOME/.ssh/config" | awk '{ print $1 }')" = '-rw-------' ]
install_ssh
cmp "$test_dir/entry" "$HOME/.ssh/config"
effective_config > "$test_dir/enabled"
command grep -qx 'serveraliveinterval 60' "$test_dir/enabled"
command grep -qx 'serveralivecountmax 3' "$test_dir/enabled"
command grep -qx 'connecttimeout 15' "$test_dir/enabled"
command grep -qx 'sendenv COLORTERM' "$test_dir/enabled"
uninstall_ssh
[ ! -e "$HOME/.ssh/config.d/00-dot.conf" ]
effective_config > "$test_dir/removed"
ssh -G -F /dev/null host-a 2>/dev/null > "$test_dir/defaults"
cmp "$test_dir/defaults" "$test_dir/removed"
cmp "$test_dir/inactive-fragment" "$HOME/.ssh/config.d/90-existing.conf"

# Existing configuration, including a symlink, is never rewritten.
cat > "$test_dir/original" <<'CONFIG'
Host host-a
    User alice
    ServerAliveInterval 120
Host *
    ConnectTimeout 45
CONFIG
cp "$test_dir/original" "$HOME/.ssh/config"
cp "$test_dir/original" "$test_dir/expected-original"
install_ssh
cmp "$test_dir/original" "$HOME/.ssh/config"
uninstall_ssh
rm "$HOME/.ssh/config"
ln -s "$test_dir/original" "$HOME/.ssh/config"
install_ssh
[ -L "$HOME/.ssh/config" ]
cmp "$test_dir/expected-original" "$HOME/.ssh/config"
uninstall_ssh
rm "$HOME/.ssh/config"

# Simulate explicitly placing the Include first in an existing config.
{
    cat "$test_dir/entry"
    printf '%s\n' 'Include ~/.ssh/config.d/90-existing.conf'
    cat "$test_dir/original"
} > "$HOME/.ssh/config"
printf 'Host *\n    ServerAliveCountMax 9\n' > "$test_dir/other-fragment"
cp "$test_dir/other-fragment" "$HOME/.ssh/config.d/90-existing.conf"
effective_config > "$test_dir/baseline"
command grep -qx 'serveralivecountmax 9' "$test_dir/baseline"
install_ssh
effective_config > "$test_dir/enabled"
command grep -qx 'user alice' "$test_dir/enabled"
command grep -qx 'serveraliveinterval 60' "$test_dir/enabled"
command grep -qx 'serveralivecountmax 3' "$test_dir/enabled"
command grep -qx 'connecttimeout 15' "$test_dir/enabled"
cp "$HOME/.ssh/config" "$test_dir/with-include"
install_ssh
cmp "$test_dir/with-include" "$HOME/.ssh/config"
rm "$HOME/.ssh/config.d/00-dot.conf"
effective_config > "$test_dir/deleted"
cmp "$test_dir/baseline" "$test_dir/deleted"
install_ssh
uninstall_ssh
effective_config > "$test_dir/uninstalled"
cmp "$test_dir/baseline" "$test_dir/uninstalled"
cmp "$test_dir/with-include" "$HOME/.ssh/config"
cmp "$test_dir/other-fragment" "$HOME/.ssh/config.d/90-existing.conf"

# Conflicts must fail before touching the destination, main config or state.
for conflict in file symlink dangling directory; do
    export HOME="$test_dir/$conflict" XDG_STATE_HOME="$test_dir/$conflict-state"
    mkdir -p "$HOME/.ssh/config.d"
    cp "$test_dir/original" "$HOME/.ssh/config"
    target="$HOME/.ssh/config.d/00-dot.conf"
    case $conflict in
        file) cp "$test_dir/original" "$target" ;;
        symlink) ln -s "$test_dir/original" "$target" ;;
        dangling) ln -s "$test_dir/missing" "$target" ;;
        directory) mkdir "$target" ;;
    esac
    if install_ssh; then
        printf 'Installation unexpectedly accepted a %s conflict\n' "$conflict" >&2
        exit 1
    fi
    case $conflict in
        file) [ ! -L "$target" ]; cmp "$test_dir/original" "$target" ;;
        symlink) [ "$(readlink "$target")" = "$test_dir/original" ] ;;
        dangling) [ "$(readlink "$target")" = "$test_dir/missing" ] ;;
        directory) [ -d "$target" ]; [ ! -e "$target/config" ] ;;
    esac
    [ ! -e "$target.bk" ] && [ ! -L "$target.bk" ]
    [ ! -e "$XDG_STATE_HOME/dot/apps" ]
    cmp "$test_dir/expected-original" "$test_dir/original"
    cmp "$test_dir/original" "$HOME/.ssh/config"
done

# An unrelated backup must neither block install nor be restored on uninstall.
export HOME="$test_dir/backup" XDG_STATE_HOME="$test_dir/backup-state"
mkdir -p "$HOME/.ssh/config.d"
target="$HOME/.ssh/config.d/00-dot.conf"
cp "$test_dir/original" "$target.bk"
install_ssh
uninstall_ssh
[ ! -e "$target" ] && [ ! -L "$target" ]
cmp "$test_dir/original" "$target.bk"

# Other apps retain their existing backup-and-restore behavior.
export DOT_DIR="$PWD"
source apps/shell/apps.sh
APPS_DIR="$test_dir/apps"
mkdir -p "$APPS_DIR/fixture"
printf 'managed\n' > "$APPS_DIR/fixture/config"
cat > "$APPS_DIR/fixture/app.sh" <<'APP'
desc="Fixture app"
link=("config:$HOME/fixture.conf")
APP
cp "$test_dir/original" "$HOME/fixture.conf"
link_replace=0
app_run install fixture > "$test_dir/fixture.log"
[ "$app_failed" -eq 0 ]
[ -L "$HOME/fixture.conf" ]
cmp "$test_dir/original" "$HOME/fixture.conf.bk"
app_run uninstall fixture >> "$test_dir/fixture.log"
[ "$app_failed" -eq 0 ]
cmp "$test_dir/original" "$HOME/fixture.conf"
printf '%s\n' 'SSH installation and removable defaults passed'
