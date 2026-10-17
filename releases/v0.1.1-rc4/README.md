# macMAKE v0.1.1-rc4 GNU corresponding-source set

This staged source set is prepared for the macMAKE v0.1.1-rc4 Linux
x86-64 candidate. It covers the distributed GNU PowerPC toolchain inputs
documented in the v0.1.0 source bundle and adds the independent GNU M68000
compiler and Binutils configuration used by the v0.1.1 candidate.

The corresponding-source archive contains the previously published complete
v0.1.0 source bundle byte-for-byte as `base/` plus the M68000 build scripts,
configuration and provenance in `m68k/`. The base bundle contains the full
GCC 12.2.0 and Binutils 2.46.1 upstream source archives, the PowerPC GCC
modification, PowerPC build instructions, runtime source/build information,
license notices and source/binary identity records. The added M68000 provider
uses those same upstream archives without additional GCC or Binutils patches.

The M68000 toolchain configuration identifies `m68k-unknown-elf`, the M68000
instruction baseline, compiler and assembler configuration, build scripts,
distributed `libgcc.a` hash, and the hashes of the packaged GCC, Binutils,
frontend and runtime files. `m68k/README.md` describes reproducing the GNU
components from the included source archives. This release identity does not
contain proprietary macMAKE source, private project history, Apple or
Metrowerks SDK material, ROMs, or operating-system images.

The staged immutable tag name is `macmake-v0.1.1-rc4-toolchain-sources`.
This is a source-release preparation record; it has not been published. The
binary candidate must not be publicly distributed until the source asset and
applicable notices are publicly accessible.
