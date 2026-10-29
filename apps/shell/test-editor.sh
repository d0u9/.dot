#!/bin/bash
# Run with bash or zsh; only fixture executables are visible to the aliases.
set -eu
DOT_DIR=${1:?Pass the repository root}
DOT_BASH_DIR=$DOT_DIR/apps/bash
DOT_ZSH_DIR=$DOT_DIR/apps/zsh
editor_test_dir=$(mktemp -d)
editor_test_path=$PATH
trap 'PATH=$editor_test_path; rm -rf -- "$editor_test_dir"' EXIT
mkdir -p "$editor_test_dir/bin" "$editor_test_dir/custom"
for editor_test_binary in bin/vi custom/nvim; do
    printf '#!/bin/sh\nexit 0\n' > "$editor_test_dir/$editor_test_binary"
    chmod +x "$editor_test_dir/$editor_test_binary"
done
PATH=$editor_test_dir/bin

check_editor() {
    EDITOR=$1 VISUAL=$1
    if [ -n "${ZSH_VERSION:-}" ]; then
        source "$DOT_ZSH_DIR/core/aliases.zsh"
    else
        source "$DOT_BASH_DIR/aliases.bash"
    fi
    if [ "$EDITOR" != "$2" ] || [ "$VISUAL" != "$2" ]; then
        printf 'FAIL: editor %s should become %s\n' "$1" "$2" >&2
        exit 1
    fi
}

check_editor '' vi
check_editor nvim vi
check_editor "$editor_test_dir/missing/nvim --clean" vi
check_editor "$editor_test_dir/custom/nvim --clean" "$editor_test_dir/custom/nvim --clean"
check_editor nano vi

PATH=$editor_test_path
cp "$editor_test_dir/custom/nvim" "$editor_test_dir/bin/nvim"
PATH=$editor_test_dir/bin
check_editor vi nvim
check_editor 'nvim --clean' 'nvim --clean'
check_editor "$editor_test_dir/missing/nvim" nvim
printf 'Editor availability, priority and arguments passed\n'
