# macmake-gpl corresponding source for macMAKE v0.1.0

This repository contains corresponding source material for the GNU GCC and GNU Binutils programs distributed as separate toolchain components with the macMAKE v0.1.0 Linux x86-64 release. It does not contain proprietary macMAKE source or user-supplied Apple and Metrowerks development files.

The immutable source identity for the macMAKE v0.1.0 binary is `macmake-v0.1.0-toolchain-sources`. The release package includes complete upstream GCC 12.2.0 and GNU Binutils 2.46.1 source archives, the exact GCC target patch, build and configuration scripts, GCC runtime-support build material, license texts, packaged-component hashes, and provenance records. The archive is the authoritative complete source bundle; hashes and release identity are recorded in `corresponding-source-manifest.json` and the release archive metadata.

The distributed GCC C compiler produces PowerPC target code for `powerpc-unknown-macmake`. It is configured with the C frontend and without libstdc++; C++ ABI/runtime parity is outside the supported v0.1.0 scope. The target `libgcc.a` and `crtdbase.o` are included in the toolchain. Individual source notices determine where the GCC Runtime Library Exception applies. The C-only sample does not link `crtdbase.o`; C++-source paths may select it.

GCC, Binutils, runtime files, and this source material retain their own applicable licenses. The proprietary macMAKE binary license does not apply to these components. This source package is not a legal opinion; qualified review should assess the actual distribution and compilation/linking workflows.

See `corresponding-source-manifest.json`, `distribution-transform.json`, `gcc/runtime-support.json`, and the component build evidence for the source and binary identities.

## Staged v0.1.1-rc4 source addition

The local branch `release/v0.1.1-rc4-corresponding-source` adds the M68000
GNU toolchain recipes and configuration under `m68k/`. Its staged source
identity is documented in `releases/v0.1.1-rc4/README.md`; the complete
source-release manifest is in that directory. It reuses the exact upstream
GCC and Binutils source archives already carried by the v0.1.0 bundle and
adds the M68000 build configuration, component hashes and scripts. This
branch and its source archive have not been published. The published v0.1.0
source tag and release asset remain unchanged.
