#!/bin/bash
set -euo pipefail
cd -- "$(dirname -- "$0")/../../.."
source apps/bash/app.sh

# Stub host commands so the installer never touches installed packages.
command_exist() { [ "$1" = brew ]; }
bash() { local script=${2//BASH_VERSINFO/test_version}; eval "$script"; }
brew() { [ "${installed:-}" = "$3" ] && echo "$3 1.0"; }
pkg_install() { printf '%s\n' "$1"; }
info() { :; }
warn() { printf '%s\n' "$*" >&2; }

for version in 3.2 4.1 4.2 5.0; do
    test_version=(${version/./ })
    case $version in 3.2|4.1) expected=bash-completion ;; *) expected=bash-completion@2 ;; esac
    installed=
    [ "$(post)" = "$expected" ]
    installed=$expected
    [ -z "$(post)" ]
    installed=other-formula
    [ "$(post)" = "$expected" ]
done

bash() { return 1; }
[ -z "$(post 2>/dev/null)" ]
echo 'Bash completion package selection passed'
