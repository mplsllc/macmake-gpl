# macMAKE-controlled classic M68K application toolchain

This directory documents the independent compiler/toolchain build for classic
Motorola 68K targets. macMAKE uses upstream GNU GCC and Binutils for C code
generation, assembly, ELF linking, and generic ELF-to-binary extraction. The
Classic Macintosh application model is implemented in macMAKE. This path does
not invoke Retro68, `Elf2Mac`, or Retro68 `Rez`.

## Pinned upstream inputs

| Component | Version | Source SHA-256 | License |
|---|---:|---|---|
| GNU Binutils | 2.46.1 | `e127a709cba24c76de8936cb7083dd768f28cd37eb010492e2f19b71eb1294e4` | GPL-3.0-or-later; component notices are in upstream source |
| GNU GCC | 12.2.0 | `e549cf9cf3594a00e27b6589d4322d70e0720cdd213f39beb4181e06926230ff` | GPL-3.0-or-later; libgcc files retain their own runtime-exception notices |

The exact tarballs were verified inside the published v0.1.0 GCC/Binutils
corresponding-source archive. The PPC-specific macMAKE GCC patch is not used.
No Retro68 source, patch, binary, runtime, or resource tool is an input.

## Bootstrap the cross compiler

Provide extracted, checksum-verified upstream source trees and separate build
and installation directories:

```sh
toolchains/classic-m68k/build-binutils.sh \
  /path/to/binutils-2.46.1 /path/to/build/binutils \
  /path/to/install/m68k-unknown-elf

toolchains/classic-m68k/build-compiler.sh \
  /path/to/gcc-12.2.0 /path/to/build/gcc \
  /path/to/install/m68k-unknown-elf \
  /path/to/install/m68k-unknown-elf
```

The GCC recipe pins the default compiler CPU to M68000 using upstream GCC's
`--with-arch=m68k --with-cpu=m68000` configuration. A first compiler-only
regression fixture can be run with:

```sh
toolchains/classic-m68k/tests/compile-link-smoke.sh \
  /path/to/install/m68k-unknown-elf
```

That fixture clears the process environment, compiles two C89 translation
units, assembles a 68000 entry probe, and links an ELF32 big-endian EM_68K
image with GNU `ld`. It confirms compiler, assembler, and generic ELF linker
provenance only. It does not produce or validate a Macintosh application.

The compiler is configured for the Motorola 68000 instruction baseline and
produces ELF32 big-endian M68K objects for `m68k-unknown-elf`. The current
ordinary-app profile is intentionally restricted: C89, one near-model code
segment, PC-relative references, no external linked libraries, and no CFM
fragments. Initialized and zero-initialized application globals are stored in
the same file-backed CODE 1 image as the code; this avoids a separate A5 data
initializer in the current single-segment profile. The flat image is limited
to 32,760 bytes so the selected PC-relative references remain in range.

## Normal `macmake build` path

For `classic-68k-segmented-app-c-v1`, the current implementation performs:

1. `m68k-unknown-elf-gcc` compiles each `.c` translation unit with the
   M68000, 16-bit `int`, PC-relative, freestanding flags recorded by the CLI.
2. The same GCC driver assembles macMAKE-owned `start.S` and Toolbox trap
   veneers. It also compiles macMAKE-owned `memory.c` (`memcpy`/`memset`).
3. `m68k-unknown-elf-ld` links those objects and the selected GCC `libgcc.a`
   under `classic-segmented-app.ld`. Writable `.data` and `.bss` sections must
   be file-backed allocatable contents, are included in the flat code image,
   and are checked against the image's PC-relative size limit. The CLI also
   checks ELF32/big-endian/EM_68K/entry-zero and no remaining relocations.
4. `m68k-unknown-elf-objcopy -O binary` extracts a generic flat code image.
   This is generic GNU ELF processing, not an application-format converter.
5. macMAKE constructs the classic CODE 0 header/jump entry and CODE 1 near
   segment header in `crates/macmake-cli/src/native_m68k_application.rs`.
   CODE 0 reserves the QuickDraw A5 area; the application's own C globals use
   PC-relative addresses within the loaded CODE 1 image.
6. macMAKE compiles the supported in-process Rez subset, then
   `macmake-classic` creates the resource fork with CODE 0, CODE 1, SIZE,
   project resources, Finder metadata (APPL and the selected creator), and
   MacBinary II output. The current resource subset includes `vers`, `STR#`,
   Pascal-string aliases, `FREF`, `ICN#`, and `BNDL`; unsupported Rez syntax
   fails with a diagnostic.

The first end-to-end independence check is
`tests/macmake-provider-isolation.sh`. It builds both a two-translation-unit
C probe and `fixtures/016-hello-window-m68k-native` with a clean environment,
poisoned `RETRO68_ROOT` and `MACMAKE_TOOLCHAIN_ROOT`, and only the explicit
M68K GNU prefix. It also verifies the packaged artifact with the standard
macMAKE artifact inspector. The owner confirmed the resulting HelloWindow
opened, displayed its message, and worked on Mac OS 8.1. This is HelloWindow
evidence, separate from makePAD's application-specific evidence.

The supported route is selected only for the explicit manifest profile
`classic-68k-segmented-app-c-v1`. A missing or mismatched M68K toolchain fails
with an actionable error; neither Retro68 variables nor the generic PPC
provider can select or satisfy this provider.

## makePAD 68K application result

The same six C89 makePAD translation units used by the PowerPC application
build through the native M68K CLI target `Mac OS 8.1 68K Native`. The final
owner-tested MacBinary is archived at the public macMAKE repository's
`makeAPPS/makePAD/v0.1/FINAL/` directory. Its SHA-256 is
`097d8e54a505f4dd0d5a1969af2ae8a490b124986b0907bae84875dfd58842a6`.
Owner testing on 2026-10-16 reported full operation on Mac OS 8.1 and an
unspecified System 7 release; Mac OS 8.0, 7.6.1, 7.6, and 7.5.5 worked except
that opening a saved document directly from Finder failed; Mac OS 6.0.8 quit
with error (1). These are makePAD-specific observations, not general OS
compatibility claims. See the public archive's `FINAL/RUNTIME-RESULTS.md` for
the exact record and limitations.

See `toolchain.json` for source and binary hashes, configuration, and current
validation records.
