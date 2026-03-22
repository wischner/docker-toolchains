# GCC x86_64 Windows MinGW-w64 Toolchain

`wischner/gcc-x86_64-windows-mingw-w64` is a ready-to-use Ubuntu 22.04 Docker image for **cross-compiling Windows x64 applications** from Linux.

It provides the MinGW-w64 GNU toolchain (`x86_64-w64-mingw32-*`) plus practical packaging/signing/testing helpers for CI and release workflows.

## What is included

- GCC and G++ cross compilers for `x86_64-w64-mingw32`
- MinGW-w64 binutils and development headers/libs
- CMake, Make, pkg-config
- GDB + GDB MinGW
- Wine64
- NSIS (`makensis`)
- `osslsigncode`
- Cross-target libraries available in Ubuntu:
  - zlib (`libz-mingw-w64-dev`)
  - win-iconv (`win-iconv-mingw-w64-dev`)
  - MinGW variants of `libgpg-error`, `libgcrypt`, `libassuan`, `libksba`, `libnpth`
- CMake toolchain file: `/opt/toolchains/mingw-w64-x86_64.cmake`

## What this image is for

- Cross-compiling Windows x64 executables and DLLs
- CMake Windows-target CI builds on Linux runners
- Producing signed/packaged Windows artifacts in containerized pipelines

## Quick start

Compile a C program:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-windows-mingw-w64:latest \
  x86_64-w64-mingw32-gcc -O2 -o hello.exe hello.c
```

Compile using CMake:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-windows-mingw-w64:latest \
  bash -c "cmake -S . -B build-win -DCMAKE_TOOLCHAIN_FILE=/opt/toolchains/mingw-w64-x86_64.cmake && cmake --build build-win -j"
```

Run a quick smoke test under Wine:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-windows-mingw-w64:latest \
  wine64 ./hello.exe
```

## Related images

- `wischner/gcc-x86_64-linux-x11`
- `wischner/gcc-x86_64-linux-sdl`

## Support

Issues and pull requests are welcome:
<https://github.com/wischner/docker-toolchains>
