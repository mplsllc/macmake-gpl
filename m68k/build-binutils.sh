#!/bin/sh
set -eu

if [ "$#" -ne 3 ]; then
    echo "usage: build-binutils.sh <binutils-source> <build-dir> <install-prefix>" >&2
    exit 2
fi

source_dir=$(CDPATH= cd -- "$1" && pwd)
build_dir=$2
prefix=$3

test -x "$source_dir/configure" || {
    echo "not a GNU Binutils source tree: $source_dir" >&2
    exit 1
}
mkdir -p "$build_dir"
build_dir=$(CDPATH= cd -- "$build_dir" && pwd)
mkdir -p "$prefix"
prefix=$(CDPATH= cd -- "$prefix" && pwd)

if [ ! -f "$build_dir/Makefile" ]; then
    (
        cd "$build_dir"
        "$source_dir/configure" \
        --target=m68k-unknown-elf \
        --prefix="$prefix" \
        --disable-nls \
        --disable-werror \
        --disable-gdb \
        --disable-gprofng
    )
fi

jobs=${MACMAKE_BUILD_JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2)}
make -C "$build_dir" -j"$jobs"
make -C "$build_dir" install

"$prefix/bin/m68k-unknown-elf-as" --version | sed -n '1,2p'
"$prefix/bin/m68k-unknown-elf-ld" --version | sed -n '1,2p'
