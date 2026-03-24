# GCC x86_64 Haiku

GCC cross-compiler for Haiku OS (x86_64-unknown-haiku target).

## What's included

### Core toolchain
- **GCC cross-compiler** (x86_64-unknown-haiku-gcc, g++)
- **Binutils** (as, ld, ar, objcopy, objdump, ranlib, strip, nm)
- **Standard libraries** (libgcc, libstdc++, libsupc++)

### Haiku headers and sysroot
- **Haiku headers** - OS and POSIX headers included with the cross-compiler
- **Cross-compiler sysroot** - Built-in sysroot at `build/cross-tools-x86_64/x86_64-unknown-haiku/`
- **Haiku source tree** - Full sources at `/opt/haiku-buildtools/haiku` for reference

**Note:** This toolchain includes Haiku runtime libraries and **can link complete executables**.

### Build tools
- **Jam** build system (Haiku's BeOS-style build tool)
- Essential build tools (git, python3, perl, cmake, make, nasm, autotools)

This is a **cross-compilation toolchain** for compiling and linking complete Haiku C/C++ executables. The toolchain includes Haiku runtime libraries extracted into the sysroot.

## Base image

- Ubuntu 22.04 LTS (needed for glibc compatibility with Haiku's build system)
- Haiku buildtools at `/opt/haiku-buildtools`
- Cross-tools in PATH

## Usage

### Interactive shell

```bash
docker run --rm -it \
  -v "$(pwd)":/work -w /work \
  wischner/gcc-x86_64-haiku:latest \
  bash
```

### Compile and link executables

```bash
docker run --rm -it \
  -v "$(pwd)":/work -w /work \
  wischner/gcc-x86_64-haiku:latest \
  x86_64-unknown-haiku-gcc hello.c -o hello
```

The toolchain can compile and link complete Haiku executables.

### Build with Jam

```bash
docker run --rm -it \
  -v "$(pwd)":/work -w /work \
  wischner/gcc-x86_64-haiku:latest \
  jam
```

## Environment variables

- `HAIKU_TOOLCHAIN_PATH=/opt/haiku-buildtools` - Base path for Haiku tools
- `HAIKU_SOURCE=/opt/haiku-buildtools/haiku` - Haiku source tree
- `HAIKU_SYSROOT=/opt/haiku-buildtools/build/cross-tools-x86_64/sysroot` - Cross-compiler sysroot
- `HAIKU_REVISION=auto` - Resolved during build from the selected HPKG pair
- `PATH` includes cross-compiler binaries from `${HAIKU_TOOLCHAIN_PATH}/build/cross-tools-x86_64/bin`

The sysroot contains a complete Haiku runtime overlay at `${HAIKU_SYSROOT}/boot/system` with libraries and development headers.
Resolved package metadata is written to `/opt/haiku-buildtools/haiku-package-info.env` inside the image.

## Using Haiku headers

To compile with Haiku system headers, reference the source tree:

```bash
x86_64-unknown-haiku-gcc \
  -I${HAIKU_SOURCE}/headers/os \
  -I${HAIKU_SOURCE}/headers/posix \
  -o hello hello.c
```

Or let the compiler find them automatically (they should be in the default include path).

## Target architecture

This image builds for **x86_64-unknown-haiku** (64-bit Haiku).

## Version pinning

The Haiku source/package selection is configured in `build.args`:
- `HAIKU_COMMIT` - Git branch/tag of Haiku repositories (default: `master`)
- `HAIKU_PACKAGE_MIRROR` - package mirror base URL (default: EU mirror)
- `HAIKU_PACKAGE_BRANCH` - package branch path on mirror (default: `master`)
- `HAIKU_PACKAGE_ARCH` - package architecture (default: `x86_64`)
- `HAIKU_PACKAGE_VERSION` - package version (`latest` by default, or explicit like `r1~beta5_hrev59523`)
- `HAIKU_NIGHTLY_INDEX_URL` - nightly index page used to detect latest `hrev`
- `IMG_VERSION` - Docker image version

## Building from source

By default, the build automatically:
1. reads the latest nightly revision from the EU nightly index
2. resolves the matching package version on the EU package mirror
3. downloads:
   - `haiku-<version>-1-x86_64.hpkg`
   - `haiku_devel-<version>-1-x86_64.hpkg`

Optional override: place local `.hpkg` files in `packages/` to use those instead of downloading. See [packages/README.md](packages/README.md).

The Haiku cross-compilation toolchain is built during image creation:
1. Clone Haiku buildtools and main repositories (with tags for proper versioning)
2. Configure and build cross-compilation toolchain (GCC, binutils, standard libraries)
3. Build Haiku package tool
4. Resolve (or use local override), download, and extract Haiku runtime packages into sysroot overlay
5. Build and install Jam build system
6. Clean up build artifacts

The build process takes approximately **30-45 minutes** and results in a complete cross-compilation toolchain for building Haiku executables.

For debugging builds, you can use:
```bash
make DOCKER_BUILD_FLAGS="--progress=plain --no-cache" build-gcc-x86_64-haiku
```

## Size considerations

This is a **complete cross-compilation toolchain** including:
- GCC cross-compiler with Haiku sysroot
- Binutils
- Haiku runtime libraries (libroot.so, crt*.o, etc.)
- Haiku development headers
- Haiku source tree (for reference)
- Jam build system

Build artifacts are cleaned up to minimize size. Expected image size: ~2-3 GB.

The image can compile and link complete Haiku executables.

## License

This image bundles:
- Haiku buildtools (MIT License)
- GCC (GPL-3.0)
- Binutils (GPL-3.0)
- Ubuntu components and build dependencies (various open source licenses)

See component documentation for full license details.
