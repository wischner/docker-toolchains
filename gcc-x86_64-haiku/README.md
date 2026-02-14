# GCC x86_64 Haiku

GCC cross-compiler for Haiku OS (x86_64-unknown-haiku target).

## What's included

### Core toolchain
- **GCC cross-compiler** (x86_64-unknown-haiku-gcc, g++)
- **Binutils** (as, ld, ar, objcopy, objdump, ranlib, strip, nm)
- **GDB debugger** (x86_64-unknown-haiku-gdb, if built)
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
- `HAIKU_REVISION=hrev57991` - Haiku revision used for package builds
- `PATH` includes cross-compiler binaries from `${HAIKU_TOOLCHAIN_PATH}/build/cross-tools-x86_64/bin`

The sysroot contains a complete Haiku runtime overlay at `${HAIKU_SYSROOT}/boot/system` with libraries and development headers.

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

The Haiku commit/tag is specified in `build.args`:
- `HAIKU_COMMIT` - Git branch/tag of Haiku repository (default: `r1beta5`)
- `IMG_VERSION` - Docker image version

## Building from source

**IMPORTANT:** Before building, you must download the Haiku runtime packages. See [packages/README.md](packages/README.md) for instructions on obtaining:
- `haiku-hrev57991-1-x86_64.hpkg`
- `haiku_devel-hrev57991-1-x86_64.hpkg`

Place these files in the `packages/` directory before building.

The Haiku cross-compilation toolchain is built during image creation:
1. Clone Haiku buildtools and main repositories (with tags for proper versioning)
2. Configure and build cross-compilation toolchain (GCC, binutils, GDB, standard libraries)
3. Build Haiku package tool
4. Copy and extract Haiku runtime packages into sysroot overlay
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
- Binutils and GDB
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
- Alpine Linux components (various open source licenses)

See component documentation for full license details.