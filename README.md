# macmake-gpl

This repository contains the corresponding source, patches, build material, configuration files, and license notices for open-source components distributed with or utilized by **macMAKE**, as required by their respective licenses (such as the GNU General Public License v3).

> **Important Notice:**  
> This repository is **not** the macMAKE source tree. macMAKE's build engine, project model, semantic linker, PEF generation, MWOB handling, access path resolution, and CLI implementation are proprietary software and are not included in this repository.  
> The presence of GPL-covered components in this repository satisfies redistribution requirements for those specific tools and does not license macMAKE itself under the GPL.

---

## Components

### 1. GCC 12.2.0 (Target: `powerpc-unknown-macmake`)

- **Component:** GNU Compiler Collection (GCC) 12.2.0
- **Upstream Source Archive:** `https://ftp.gnu.org/gnu/gcc/gcc-12.2.0/gcc-12.2.0.tar.xz`
- **Upstream SHA-256 Digest:** `e549cf9cf3594a00e27b6589d4322d70e0720cdd213f39beb4181e06926230ff`
- **License:** GNU General Public License v3 or later ([`gcc/COPYING`](gcc/COPYING)) with GCC Runtime Library Exception
- **Modifications:** `gcc/gcc-12.2.0.patch`
  - Defines the `powerpc-unknown-macmake` target.
  - Configures rs6000 AIX-family ABI calling conventions (`ABI_AIX`, fixed GPR2, TOC, 16-byte stack boundary).
  - Emits GPR12 transition-vector placement for indirect calls.
  - Overrides subword scalar return promotion for low byte/halfword Low GPR3 extraction.
  - Enables Darwin-compatible `#pragma options align=mac68k|power|reset`.
  - Disables AIX `collect2` shared-library constructor hooks.
- **Build Recipe:** [`gcc/build-compiler.sh`](gcc/build-compiler.sh)
- **Reproduction Instructions:**
  ```sh
  cd gcc
  bash build-compiler.sh /path/to/build/root c
  ```

---

### 2. GNU Binutils 2.46.1 (Target: `powerpc-ibm-aix7.1.0.0`)

- **Component:** GNU Binutils 2.46.1 (Assembler `as` and `objdump`)
- **Upstream Source Archive:** `https://ftp.gnu.org/gnu/binutils/binutils-2.46.1.tar.xz`
- **Upstream SHA-256 Digest:** `e127a709cba24c76de8936cb7083dd768f28cd37eb010492e2f19b71eb1294e4`
- **License:** GNU General Public License v3 or later ([`binutils/COPYING`](binutils/COPYING))
- **Modifications:** None (unmodified upstream source configured for `powerpc-ibm-aix7.1.0.0`).
- **Configuration & Evidence:**
  - Manifest: [`binutils/binutils-2.46.1.json`](binutils/binutils-2.46.1.json)
  - Build evidence & verified tool digests: [`binutils/binutils-2.46.1-build-evidence.json`](binutils/binutils-2.46.1-build-evidence.json)
- **Build Recipe:** [`binutils/build-binutils.sh`](binutils/build-binutils.sh)
- **Reproduction Instructions:**
  ```sh
  cd binutils
  bash build-binutils.sh /path/to/build/root
  ```

---

## Licenses

- GNU General Public License v3: [`licenses/COPYING`](licenses/COPYING)

## Links

- macMAKE Project: [https://macmake.dev](https://macmake.dev)
- Public Project Repository: [https://github.com/mplsllc/macMAKE](https://github.com/mplsllc/macMAKE)
