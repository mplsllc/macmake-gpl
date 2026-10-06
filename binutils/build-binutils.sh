#!/usr/bin/env bash
set -euo pipefail

version=2.46.1
target=powerpc-ibm-aix7.1.0.0
sha256=e127a709cba24c76de8936cb7083dd768f28cd37eb010492e2f19b71eb1294e4
url="https://ftp.gnu.org/gnu/binutils/binutils-${version}.tar.xz"
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
work_root=${1:-"${TMPDIR:-/tmp}/macmake-binutils-${version}-clean"}
archive=${BINUTILS_ARCHIVE:-"${work_root}/binutils-${version}.tar.xz"}
source_dir="${work_root}/binutils-${version}"
build_dir="${work_root}/build"
install_dir="${work_root}/install"

mkdir -p -- "${work_root}"
if [[ ! -f "${archive}" ]]; then
    curl --fail --location --retry 3 "${url}" --output "${archive}"
fi
actual_sha=$(sha256sum "${archive}" | awk '{print $1}')
if [[ "${actual_sha}" != "${sha256}" ]]; then
    echo "binutils archive digest mismatch: ${actual_sha}" >&2
    exit 1
fi

rm -rf -- "${source_dir}" "${build_dir}" "${install_dir}"
tar -xf "${archive}" -C "${work_root}"
mkdir -p -- "${build_dir}"
cd -- "${build_dir}"
"${source_dir}/configure" \
    --target="${target}" \
    --prefix="${install_dir}" \
    --disable-nls \
    --disable-werror \
    --disable-gold \
    --disable-ld \
    --disable-gdb \
    --disable-sim \
    --disable-gprofng \
    --enable-gas \
    --enable-binutils
make -j"${JOBS:-2}" all-gas all-binutils
make install-gas install-binutils

assembler="${install_dir}/bin/${target}-as"
objdump="${install_dir}/bin/${target}-objdump"
"${assembler}" --version | head -n 1
"${objdump}" --version | head -n 1
printf 'target=%s\narchive_sha256=%s\nassembler_sha256=%s\nobjdump_sha256=%s\n' \
    "${target}" "${actual_sha}" \
    "$(sha256sum "${assembler}" | awk '{print $1}')" \
    "$(sha256sum "${objdump}" | awk '{print $1}')"
printf 'install_dir=%s\n' "${install_dir}"
