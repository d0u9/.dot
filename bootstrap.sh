#!/bin/bash

# Set up a new host: check the prerequisites, clone the repository or update
# an existing checkout, then run the installer. Without arguments the
# installer shows its checklist; any arguments are passed to it instead.
#
#   curl -fsSL https://raw.githubusercontent.com/d0u9/.dot/master/bootstrap.sh | bash
#   DOT_DIR=~/src/dot bash bootstrap.sh       choose the checkout location
#   DOT_REPO=URL bash bootstrap.sh            clone from another remote
#   bash bootstrap.sh zsh nvim                install without the checklist

set -euo pipefail

DOT_DIR=${DOT_DIR:-$HOME/.dot}
DOT_REPO=${DOT_REPO:-https://github.com/d0u9/.dot.git}

missing=
for cmd in git curl tar xz unzip; do
    command -v "$cmd" > /dev/null 2>&1 || missing="$missing $cmd"
done
[ -z "$missing" ] || { echo "bootstrap: install first:$missing" >&2; exit 1; }

if [ -d "$DOT_DIR/.git" ]; then
    git -C "$DOT_DIR" pull --ff-only
else
    git clone "$DOT_REPO" "$DOT_DIR"
fi

[ $# -gt 0 ] || set -- -m
exec "$DOT_DIR/install.sh" "$@"
