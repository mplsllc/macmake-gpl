# GNU M68000 toolchain build inputs

This directory records the build configuration used for the GNU components
distributed in the macMAKE v0.1.1 RC4 Linux x86-64 candidate. The companion
`toolchain-config.json` lists source archive hashes, configuration options,
and hashes of the distributed GNU executables and `libgcc.a`.

The complete GCC 12.2.0 and Binutils 2.46.1 source archives are included
unchanged in the nested base source archive named by
the bundle's top-level `SOURCE-MANIFEST.json`. Verify their SHA-256 values
against `toolchain-config.json`, then extract the source trees. No M68000-specific
patch is applied to either upstream source tree.

Build Binutils for `m68k-unknown-elf`:

```sh
m68k/build-binutils.sh \
  /path/to/binutils-2.46.1 /path/to/build/binutils \
  /path/to/install/m68k-unknown-elf
```

Build GCC and target `libgcc` with the M68000 instruction baseline:

```sh
m68k/build-compiler.sh \
  /path/to/gcc-12.2.0 /path/to/build/gcc \
  /path/to/install/m68k-unknown-elf \
  /path/to/install/m68k-unknown-elf
```

These scripts describe the configuration and build/install targets used for
the distributed GNU programs. They do not build or replace the separate
proprietary macMAKE application-output implementation. GCC runtime files keep
their individual upstream notices; inspect the included GCC source file
notices to determine which units carry the GCC Runtime Library Exception.
