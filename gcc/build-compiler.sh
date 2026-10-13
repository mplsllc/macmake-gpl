#!/usr/bin/env bash
set -euo pipefail

# Build a relocatable macMAKE-owned compiler from pinned upstream GCC source.
# C is the supported frontend; C++ remains experimental and unqualified.
# A target assembler enables construction of the GCC runtime archive and is
# required for a complete distributable provider.
toolchain_root=${1:?usage: build-compiler.sh BUILD_ROOT [c|c,c++]}
compiler_languages=${2:-c}
target_assembler=${MACMAKE_PPC_AS:-}
target_tools_dir=
target_ar=
target_ranlib=
case "$compiler_languages" in
    c|c,c++) ;;
    *) printf 'supported frontend sets are c and c,c++\n' >&2; exit 2 ;;
esac
if [[ -n "$target_assembler" ]]; then
    if [[ ! -x "$target_assembler" ]]; then
        printf 'target assembler is not executable: %s\n' "$target_assembler" >&2
        exit 2
    fi
    assembler_dir=$(cd -- "$(dirname -- "$target_assembler")" && pwd)
    target_prefix=powerpc-ibm-aix7.1.0.0
    target_ar="$assembler_dir/${target_prefix}-ar"
    target_ranlib="$assembler_dir/${target_prefix}-ranlib"
    if [[ ! -x "$target_ar" || ! -x "$target_ranlib" ]]; then
        printf 'target ar and ranlib must be beside the configured XCOFF assembler\n' >&2
        exit 2
    fi
fi
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
    if grep -Fq -- '--disable-libgcc' "$build_root/config.status"; then
        printf 'existing GCC build has libgcc disabled; use a fresh build root for a complete provider\n' >&2
        exit 1
    fi
fi
if [[ ! -f "$build_root/Makefile" ]]; then
    if [[ -n "$target_assembler" ]]; then
        # GCC's generated target-tool wrappers require an assembler path at
        # configure time. Passing it only to make leaves gcc/as with an empty
        # ORIGINAL_AS_FOR_TARGET and breaks target runtime builds. GCC's
        # --with-build-time-tools interface uses the standard unqualified
        # tool names, so provide aliases without changing the installed
        # compiler's target triple or the user's canonical tool names.
        target_tools_dir="$build_root/build-time-tools"
        mkdir -p "$target_tools_dir"
        ln -sfn -- "$target_assembler" "$target_tools_dir/as"
        ln -sfn -- "$target_ar" "$target_tools_dir/ar"
        ln -sfn -- "$target_ranlib" "$target_tools_dir/ranlib"
        for tool in nm objdump objcopy strip; do
            candidate="$assembler_dir/${target_prefix}-${tool}"
            if [[ -x "$candidate" ]]; then
                ln -sfn -- "$candidate" "$target_tools_dir/$tool"
            fi
        done
    fi
    (
        cd "$build_root"
        configure_args=(
            --target=powerpc-unknown-macmake \
            --enable-languages="$compiler_languages" \
            --disable-bootstrap \
            --disable-multilib \
            --disable-libstdcxx \
            --without-headers \
            --prefix="$toolchain_root/install"
        )
        if [[ -n "$target_tools_dir" ]]; then
            configure_args+=("--with-build-time-tools=$target_tools_dir")
        fi
        "$source_root/configure" "${configure_args[@]}"
    )
fi
build_jobs=${MACMAKE_BUILD_JOBS:-$(nproc)}
if [[ -n "$target_assembler" ]]; then
    make -C "$build_root" -j"$build_jobs" \
        "AS_FOR_TARGET=$target_assembler" \
        "AR_FOR_TARGET=$target_ar" \
        "RANLIB_FOR_TARGET=$target_ranlib" \
        all-gcc
    make -C "$build_root" \
        "AS_FOR_TARGET=$target_assembler" \
        "AR_FOR_TARGET=$target_ar" \
        "RANLIB_FOR_TARGET=$target_ranlib" \
        install-gcc
    if [[ ! -x "$build_root/gcc/as" ]] || ! grep -Fq "$target_assembler" "$build_root/gcc/as"; then
        printf 'configured GCC assembler wrapper does not reference %s\n' "$target_assembler" >&2
        exit 1
    fi
    make -C "$build_root" -j"$build_jobs" \
        "AS_FOR_TARGET=$target_assembler" \
        "AR_FOR_TARGET=$target_ar" \
        "RANLIB_FOR_TARGET=$target_ranlib" \
        all-target-libgcc
    make -C "$build_root" \
        "AS_FOR_TARGET=$target_assembler" \
        "AR_FOR_TARGET=$target_ar" \
        "RANLIB_FOR_TARGET=$target_ranlib" \
        install-target-libgcc
    bash "$script_root/build-runtime-support.sh" \
        "$toolchain_root" "$target_assembler" "$toolchain_root/install"
    runtime_archive=$("$toolchain_root/install/bin/powerpc-unknown-macmake-gcc" -print-libgcc-file-name)
    if [[ ! -f "$runtime_archive" ]]; then
        printf 'installed GCC runtime archive was not produced: %s\n' "$runtime_archive" >&2
        exit 1
    fi
    runtime_members=$("$target_ar" t "$runtime_archive")
    for required_member in _muldi3.o _divdi3.o _floatundidf.o __main.o _ctors.o; do
        if ! grep -Fxq "$required_member" <<< "$runtime_members"; then
            printf 'installed GCC runtime is missing required C support member %s\n' "$required_member" >&2
            exit 1
        fi
    done
    if grep -Eiq 'unwind|cxa|emutls' <<< "$runtime_members"; then
        printf 'C-only Classic runtime unexpectedly contains EH/C++/TLS support members\n' >&2
        exit 1
    fi
else
    make -C "$build_root" -j"$build_jobs" all-gcc
    make -C "$build_root" install-gcc
    printf 'warning: compiler-only build; set MACMAKE_PPC_AS to build/install the target libgcc runtime\n' >&2
fi
printf '%s\n' "$build_root/gcc/xgcc"
