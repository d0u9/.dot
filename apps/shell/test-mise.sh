#!/bin/bash
# Run with bash or zsh without loading a full shell or optional tools.
set -eu
DOT_DIR=${1:?Pass the repository root}
DOT_ZSH_DIR=$DOT_DIR/apps/zsh
mise_test_dir=$(mktemp -d)
mise_test_path=$PATH
trap 'PATH=$mise_test_path; rm -rf -- "$mise_test_dir"' EXIT
MISE_DATA_DIR=$mise_test_dir
PATH=$mise_test_dir

check_mise() {
    if [ -n "${ZSH_VERSION:-}" ]; then
        source "$DOT_ZSH_DIR/core/integrations.zsh"
    else
        source "$DOT_DIR/apps/bash/integrations.bash"
    fi
    if [ "$MISE_DISABLE_TOOLS" != "$1" ]; then
        printf 'FAIL: mise disable list should be %s\n' "$1" >&2
        exit 1
    fi
}

unset MISE_DISABLE_TOOLS
check_mise rust
check_mise rust
MISE_DISABLE_TOOLS=python
check_mise python,rust
check_mise python,rust
MISE_DISABLE_TOOLS=rust,python
check_mise rust,python
MISE_DISABLE_TOOLS=rustfmt
check_mise rustfmt,rust
printf 'Mise Rust exclusion and existing disable lists passed\n'
