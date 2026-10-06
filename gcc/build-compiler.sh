#!/usr/bin/env bash
set -euo pipefail

# Build a macMAKE-owned compiler from pinned upstream GCC source. This stage
# defaults to C; the optional C++ frontend is experimental and unqualified.
# Object assembly/linking is gated
# separately and must not fall back to a Retro68 installation.
toolchain_root=${1:?usage: build-compiler.sh BUILD_ROOT [c|c,c++]}
compiler_languages=${2:-c}
case "$compiler_languages" in
    c|c,c++) ;;
    *) printf 'supported frontend sets are c and c,c++\n' >&2; exit 2 ;;
esac
source_archive="$toolchain_root/gcc-12.2.0.tar.xz"
source_root="$toolchain_root/source"
build_root="$toolchain_root/build"
script_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
patch_sha256=$(sha256sum "$script_root/gcc-12.2.0.patch" | cut -d' ' -f1)
patch_stamp="$source_root/.macmake-patch-sha256"
mkdir -p "$toolchain_root"
if [[ ! -f "$source_archive" ]]; then
    curl --fail --location --silent --show-error \
        https://ftp.gnu.org/gnu/gcc/gcc-12.2.0/gcc-12.2.0.tar.xz \
        --output "$source_archive"
fi
printf '%s  %s\n' \
    e549cf9cf3594a00e27b6589d4322d70e0720cdd213f39beb4181e06926230ff \
    "$source_archive" | sha256sum --check --status
if [[ -d "$source_root" ]]; then
    if [[ ! -f "$patch_stamp" ]] || [[ $(cat "$patch_stamp") != "$patch_sha256" ]]; then
        printf 'existing GCC source has a different or unknown patch; use a fresh build root\n' >&2
        exit 1
    fi
else
    mkdir "$source_root"
    tar -xf "$source_archive" -C "$source_root" --strip-components=1
    patch --directory "$source_root" -p1 < "$script_root/gcc-12.2.0.patch"
    printf '%s\n' "$patch_sha256" > "$patch_stamp"
fi
mkdir -p "$build_root"
if [[ -f "$build_root/Makefile" ]]; then
    if [[ "$compiler_languages" == 'c,c++' ]] && ! grep -Fq 'c,c++' "$build_root/config.status"; then
        printf 'existing compiler build is C-only; use a fresh C++ build root\n' >&2
        exit 1
    fi
fi
if [[ ! -f "$build_root/Makefile" ]]; then
    (
        cd "$build_root"
        "$source_root/configure" \
            --target=powerpc-unknown-macmake \
            --enable-languages="$compiler_languages" \
            --disable-bootstrap \
            --disable-multilib \
            --disable-libgcc \
            --disable-libstdcxx \
            --without-headers \
            --prefix="$toolchain_root/install"
    )
fi
build_jobs=${MACMAKE_BUILD_JOBS:-$(nproc)}
make -C "$build_root" -j"$build_jobs" all-gcc
printf '%s\n' "$build_root/gcc/xgcc"
