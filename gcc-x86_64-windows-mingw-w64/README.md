# GCC x86_64 Windows MinGW-w64 toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is

A ready-to-use **MinGW-w64 cross-compilation environment** for building 64-bit Windows binaries (`.exe`, `.dll`) from Linux on Ubuntu 22.04.

This image provides the canonical `x86_64-w64-mingw32-*` toolchain, CMake/Make workflow support, and practical packaging/signing helpers for Windows releases.

## Installed components

- GCC/G++ cross compilers for **`x86_64-w64-mingw32`** (POSIX threading variant)
- MinGW-w64 binutils (`ld`, `ar`, `objcopy`, `windres`, `dlltool`, `nm`, ...)
- MinGW-w64 development headers and runtime import libraries
- CMake, Make, pkg-config
- GDB and GDB MinGW
- Wine64 for quick executable smoke tests
- NSIS installer builder (`makensis`)
- `osslsigncode` for Authenticode signing workflows
- Cross-target libraries available in Ubuntu repos:
  - zlib (`libz-mingw-w64-dev`)
  - win-iconv (`win-iconv-mingw-w64-dev`)
  - GnuPG stack libs (`libgpg-error`, `libgcrypt`, `libassuan`, `libksba`, `libnpth` MinGW variants)
- CMake toolchain file at `/opt/toolchains/mingw-w64-x86_64.cmake`

## Quick examples

```bash
# Compile a simple Windows console app
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-windows-mingw-w64:latest \
  x86_64-w64-mingw32-gcc -O2 -o hello.exe hello.c
```

```bash
# Compile C++ app
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-windows-mingw-w64:latest \
  x86_64-w64-mingw32-g++ -O2 -std=c++20 -o app.exe main.cpp
```

```bash
# CMake cross build
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-windows-mingw-w64:latest \
  bash -c "cmake -S . -B build-win -DCMAKE_TOOLCHAIN_FILE=/opt/toolchains/mingw-w64-x86_64.cmake && cmake --build build-win -j"
```

```bash
# Optional smoke test under Wine
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-windows-mingw-w64:latest \
  wine64 ./hello.exe
```

## Notes

- This image is focused on **64-bit Windows target builds**.
- If you later need 32-bit builds, create a sibling image using `i686-w64-mingw32-*`.

## Support and contributions

For bug reports, feature requests, or questions, please use the issue tracker:
[https://github.com/wischner/docker-toolchains/issues](https://github.com/wischner/docker-toolchains/issues)

Contributions are welcome. If you'd like to improve this image, feel free to open a pull request.
