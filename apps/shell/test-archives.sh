#!/bin/bash
# Run with bash or zsh; no interactive startup or private hooks are loaded.
set -eu
source "${1:?Pass the absolute path to apps/shell/lib.sh}"
archive_test_dir=$(mktemp -d)
trap 'rm -rf -- "$archive_test_dir"' EXIT
cd "$archive_test_dir"
mkdir -p 'parent/-demo folder'
printf 'hello\n' > 'parent/-demo folder/file.txt'
printf 'hidden\n' > 'parent/-demo folder/.hidden'
touch -t 200101020304.06 'parent/-demo folder/file.txt' 'parent/-demo folder/.hidden' 'parent/-demo folder'
same_mtime() {
    [ ! "$1" -nt "$2" ] && [ ! "$2" -nt "$1" ]
}
pack 'parent/-demo folder/' >/dev/null
[ "$PWD" = "$archive_test_dir" ]
cp 'parent/-demo folder.tar.gz' original.tar.gz
if pack 'parent/-demo folder' >/dev/null 2>&1; then exit 1; fi
cmp original.tar.gz 'parent/-demo folder.tar.gz'
mkdir unpacked
cd unpacked
unpack '../parent/-demo folder.tar.gz'
cmp './-demo folder/file.txt' '../parent/-demo folder/file.txt'
cmp './-demo folder/.hidden' '../parent/-demo folder/.hidden'
same_mtime './-demo folder/file.txt' '../parent/-demo folder/file.txt'
same_mtime './-demo folder' '../parent/-demo folder'
for archive_format in tar tar.gz tar.bz2 tar.xz zip; do
    pack -f "$archive_format" -o "../test.$archive_format" './-demo folder' >/dev/null
    unpack -d "out-$archive_format" "../test.$archive_format" >/dev/null
    cmp "out-$archive_format/-demo folder/file.txt" './-demo folder/file.txt'
    same_mtime "out-$archive_format/-demo folder/file.txt" './-demo folder/file.txt'
    same_mtime "out-$archive_format/-demo folder" './-demo folder'
done
pack --help | command grep -q -- '--format'
unpack --help | command grep -q -- '--directory'
if pack -f rar './-demo folder' >/dev/null 2>&1; then exit 1; fi
if pack -o './-demo folder/inside.tar.gz' './-demo folder' >/dev/null 2>&1; then exit 1; fi
if unpack -d >/dev/null 2>&1; then exit 1; fi
if command_exist 7zz; then
    for archive_format in 7z; do
        pack -f "$archive_format" -o "../test.$archive_format" './-demo folder' >/dev/null
        unpack -d "out-$archive_format" "../test.$archive_format" >/dev/null
        cmp "out-$archive_format/-demo folder/file.txt" './-demo folder/file.txt'
    same_mtime "out-$archive_format/-demo folder/file.txt" './-demo folder/file.txt'
    same_mtime "out-$archive_format/-demo folder" './-demo folder'
    done
    # A format with no extension proves 7zz detection takes priority.
    command 7zz a -t7z ../bundle.7z './-demo folder' >/dev/null
    mv ../bundle.7z ../bundle
    mkdir sevenzip
    ( cd sevenzip; unpack ../../bundle >/dev/null )
    cmp 'sevenzip/-demo folder/file.txt' './-demo folder/file.txt'
    printf 'broken archive\n' > ../broken.tar.gz
    if unpack ../broken.tar.gz >/dev/null 2>&1; then exit 1; fi
fi
# Force the fallback without loading any host configuration.
if [ -n "${ZSH_VERSION:-}" ]; then
    commands[7zz]=/nonexistent/7zz
else
    type() { return 1; }
fi
mkdir fallback
( cd fallback; unpack '../../parent/-demo folder.tar.gz' )
cmp 'fallback/-demo folder/file.txt' './-demo folder/file.txt'
pack -f zip -o ../fallback.zip './-demo folder' >/dev/null
unpack -d fallback-zip ../fallback.zip
cmp 'fallback-zip/-demo folder/file.txt' './-demo folder/file.txt'
same_mtime 'fallback-zip/-demo folder/file.txt' './-demo folder/file.txt'
same_mtime 'fallback-zip/-demo folder' './-demo folder'
if pack -f 7z './-demo folder' > missing-pack.log 2>&1; then exit 1; fi
command grep -q 'install 7zz' missing-pack.log
printf 'archive\n' > unsupported.cab
if unpack unsupported.cab > missing-tool.log 2>&1; then exit 1; fi
command grep -q 'install 7zz' missing-tool.log
if pack missing >/dev/null 2>&1; then exit 1; fi
if pack >/dev/null 2>&1; then exit 1; fi
printf 'archive checks passed\n'
