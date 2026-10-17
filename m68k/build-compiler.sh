#!/bin/sh
set -eu

if [ "$#" -ne 4 ]; then
    echo "usage: build-compiler.sh <gcc-source> <build-dir> <install-prefix> <binutils-prefix>" >&2
    exit 2
fi

source_dir=$(CDPATH= cd -- "$1" && pwd)
build_dir=$2
prefix=$3
binutils_prefix=$(CDPATH= cd -- "$4" && pwd)

test -x "$source_dir/configure" || {
    echo "not a GNU GCC source tree: $source_dir" >&2
    exit 1
}
test -x "$binutils_prefix/bin/m68k-unknown-elf-as" || {
    echo "macMAKE M68K Binutils not found under $binutils_prefix" >&2
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
        --with-build-time-tools="$binutils_prefix/bin" \
        --with-arch=m68k \
        --with-cpu=m68000 \
        --enable-languages=c \
        --disable-bootstrap \
        --disable-multilib \
        --without-headers \
        --with-newlib \
        --disable-nls \
        --disable-werror \
        --disable-libssp \
        --disable-libquadmath \
        --disable-libgomp \
        --disable-libatomic \
        --disable-libsanitizer \
        --disable-libstdcxx \
        --disable-threads \
        --disable-shared \
        --disable-lto
    )
fi

jobs=${MACMAKE_BUILD_JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2)}
make -C "$build_dir" -j"$jobs" all-gcc all-target-libgcc
make -C "$build_dir" install-gcc install-target-libgcc

"$prefix/bin/m68k-unknown-elf-gcc" -dumpmachine
"$prefix/bin/m68k-unknown-elf-gcc" -dumpversion
"$prefix/bin/m68k-unknown-elf-gcc" -print-multi-lib
