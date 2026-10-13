#!/usr/bin/env bash
set -euo pipefail

# Build the XCOFF exception data-base startfile from pinned upstream GCC
# source. It is a separate target runtime input, not a member of libgcc.a.
toolchain_root=${1:?usage: build-runtime-support.sh BUILD_ROOT [POWERPC_AIX_AS [INSTALL_PREFIX]]}
assembler=${2:-${MACMAKE_PPC_AS:-}}
install_prefix=${3:-}
if [[ -z "$assembler" ]] || [[ ! -x "$assembler" ]]; then
    printf 'set MACMAKE_PPC_AS or pass the qualified PowerPC XCOFF assembler\n' >&2
    exit 2
fi

source_root="$toolchain_root/source"
build_root="$toolchain_root/build"
compiler="$build_root/gcc/xgcc"
runtime_source="$source_root/libgcc/config/rs6000/crtdbase.S"
if [[ ! -x "$compiler" ]]; then
    printf 'GCC target compiler not found at %s\n' "$compiler" >&2
    exit 1
fi
if [[ ! -f "$runtime_source" ]]; then
    printf 'GCC runtime source not found at %s\n' "$runtime_source" >&2
    exit 1
fi
compiler_target=$("$compiler" -dumpmachine)
if [[ "$compiler_target" != powerpc-unknown-macmake ]]; then
    printf 'expected powerpc-unknown-macmake compiler, found %s\n' "$compiler_target" >&2
    exit 1
fi
compiler_version=$("$compiler" -dumpversion)
runtime_directory="$build_root/lib/gcc/$compiler_target/$compiler_version"
mkdir -p "$runtime_directory"
temporary_root=$(mktemp -d "${TMPDIR:-/tmp}/macmake-ppc-runtime.XXXXXX")
trap 'rm -rf "$temporary_root"' EXIT

# The in-tree GCC driver uses its normal cc1 to preprocess .S input. Give it
# a temporary -B prefix for that frontend; run the selected XCOFF assembler as
# a distinct provider stage, matching macMAKE's compiler/assembler boundary.
ln -s "$build_root/gcc/cc1" "$temporary_root/cc1"
"$compiler" -B"$temporary_root/" -maix32 -E -x assembler-with-cpp \
    "$runtime_source" -o "$temporary_root/crtdbase.s"
"$assembler" -m601 -a32 -o "$temporary_root/crtdbase.o" "$temporary_root/crtdbase.s"

if [[ -n "$install_prefix" ]]; then
    installed_compiler="$install_prefix/bin/powerpc-unknown-macmake-gcc"
    if [[ ! -x "$installed_compiler" ]]; then
        printf 'installed compiler not found at %s\n' "$installed_compiler" >&2
        exit 1
    fi
    installed_archive=$("$installed_compiler" -print-libgcc-file-name)
    if [[ ! -f "$installed_archive" ]]; then
        printf 'installed target libgcc archive not found at %s\n' "$installed_archive" >&2
        exit 1
    fi
    runtime_directory=$(dirname -- "$installed_archive")
fi
install_path="$runtime_directory/crtdbase.o"
if [[ -f "$install_path" ]]; then
    if ! cmp -s "$temporary_root/crtdbase.o" "$install_path"; then
        printf 'existing crtdbase.o differs from pinned source rebuild: %s\n' "$install_path" >&2
        exit 1
    fi
    printf 'verified existing crtdbase.o against pinned source rebuild: %s\n' "$install_path"
else
    install -m 0644 "$temporary_root/crtdbase.o" "$install_path"
    printf '%s\n' "$install_path"
fi
