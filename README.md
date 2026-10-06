# macmake-gpl

This repository contains corresponding source material, patches, build scripts, configuration files, license notices, and distribution manifests for open-source components utilized by or distributed with **macMAKE**.

It is intended to provide the corresponding source required for GPL-covered components distributed with macMAKE, as required by their respective licenses (including the GNU General Public License version 3).

> **Important Boundary Notice:**  
> This repository is **not** the macMAKE source tree. macMAKE's build engine, project model, semantic linker, PEF generation, MWOB handling, access path resolution, and command-line implementation are proprietary software and are not included here.  
> macMAKE invokes GCC and GNU Binutils as separate executables using command-line arguments and filesystem objects. The macMAKE engine does not link against their program code. The GPL-covered executables and their corresponding source are distributed as separately licensed components. The presence of GPL-covered components in this repository satisfies redistribution requirements for those specific tools and does not license macMAKE itself under the GPL.

---

## Complete Corresponding Source Packages

To ensure complete, durable, and bit-identical reproducibility without committing hundreds of megabytes of third-party source into Git history, pristine upstream source tarballs are preserved in a durable release under our control:

- **Durable Release Location:** [`v0.1.0-toolchain-sources`](https://github.com/mplsllc/macmake-gpl/releases/tag/v0.1.0-toolchain-sources)
- **Machine-Readable Distribution Manifest:** [`corresponding-source-manifest.json`](corresponding-source-manifest.json)

---

## Component Details

### 1. GCC 12.2.0 (Target: `powerpc-unknown-macmake`)

- **Component:** GNU Compiler Collection (GCC) 12.2.0
- **Binary Role:** Classic PowerPC C/C++ cross-compiler frontend (`xgcc`, `cc1`, `cc1plus`)
- **Pristine Upstream Source Archive:** [`gcc-12.2.0.tar.xz`](https://github.com/mplsllc/macmake-gpl/releases/download/v0.1.0-toolchain-sources/gcc-12.2.0.tar.xz) (also at `https://ftp.gnu.org/gnu/gcc/gcc-12.2.0/gcc-12.2.0.tar.xz`)
- **Pristine Archive SHA-256 Digest:** `e549cf9cf3594a00e27b6589d4322d70e0720cdd213f39beb4181e06926230ff`
- **License:** GNU General Public License v3 or later ([`gcc/COPYING`](gcc/COPYING)).
  - *Runtime Library Exception Note:* GCC itself is licensed under GPLv3. The GCC Runtime Library Exception concerns runtime-library code linked into target executables produced by an eligible compilation process; however, this toolchain build specifically configures `--disable-libgcc` and `--disable-libstdcxx`. The Exception is not the reason macMAKE can execute the GCC compiler.
- **macMAKE Modifications:** [`gcc/gcc-12.2.0.patch`](gcc/gcc-12.2.0.patch)
  - **Patch SHA-256:** `bc37e4d7c7de86ccec1fb4bfc3c768d2e29cbfe68ace301fccfde01eb59b8c63`
  - Defines the `powerpc-unknown-macmake` target.
  - Retains rs6000 AIX-family ABI mechanics (`ABI_AIX`, fixed GPR2, TOC, 16-byte stack boundary).
  - Emits GPR12 transition-vector placement for indirect calls.
  - Overrides rs6000 subword scalar return promotion for caller low-byte/halfword GPR3 extraction.
  - Enables Darwin-compatible `#pragma options align=mac68k|power|reset`.
  - Disables AIX `collect2` shared-library constructor hooks.
- **Build Script:** [`gcc/build-compiler.sh`](gcc/build-compiler.sh)
- **Reproduction Instructions:**
  ```sh
  cd gcc
  bash build-compiler.sh /path/to/build/root c
  ```

---

### 2. GNU Binutils 2.46.1 (Target: `powerpc-ibm-aix7.1.0.0`)

- **Component:** GNU Binutils 2.46.1
- **Binary Role:** Classic PowerPC assembler (`as`) and object dumper (`objdump`)
- **Pristine Upstream Source Archive:** [`binutils-2.46.1.tar.xz`](https://github.com/mplsllc/macmake-gpl/releases/download/v0.1.0-toolchain-sources/binutils-2.46.1.tar.xz) (also at `https://ftp.gnu.org/gnu/binutils/binutils-2.46.1.tar.xz`)
- **Pristine Archive SHA-256 Digest:** `e127a709cba24c76de8936cb7083dd768f28cd37eb010492e2f19b71eb1294e4`
- **License:** GNU General Public License v3 or later ([`binutils/COPYING`](binutils/COPYING))
- **macMAKE Modifications:** None (unmodified upstream source configured for `powerpc-ibm-aix7.1.0.0`).
- **Configuration & Evidence:**
  - Manifest: [`binutils/binutils-2.46.1.json`](binutils/binutils-2.46.1.json)
  - Build evidence & verified tool digests: [`binutils/binutils-2.46.1-build-evidence.json`](binutils/binutils-2.46.1-build-evidence.json)
- **Build Script:** [`binutils/build-binutils.sh`](binutils/build-binutils.sh)
- **Reproduction Instructions:**
  ```sh
  cd binutils
  bash build-binutils.sh /path/to/build/root
  ```

---

## Licenses

- GNU General Public License v3: [`licenses/COPYING`](licenses/COPYING)

## Project Links

- Project Website: [https://macmake.dev](https://macmake.dev)
- Public Project Repository: [https://github.com/mplsllc/macMAKE](https://github.com/mplsllc/macMAKE)
