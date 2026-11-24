# GCC x86_64 Windows MinGW-w64 Toolchain

**Support:** [wischner.co.uk/support](https://wischner.co.uk/support)

`wischner/gcc-x86_64-windows-mingw-w64` is a ready-to-use Ubuntu 24.04 Docker image for **cross-compiling Windows x64 applications** from Linux.

It provides the MinGW-w64 GNU toolchain (`x86_64-w64-mingw32-*`) plus practical packaging/signing/testing helpers for CI and release workflows.

## What is included

- GCC and G++ cross compilers for `x86_64-w64-mingw32`
- MinGW-w64 binutils and development headers/libs
- CMake, Make, pkg-config
- GDB + GDB MinGW
- Python 3
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

## CONTRIBUTE

Contributions are welcome. Please open an issue or pull request:
<https://github.com/wischner/docker-toolchains>

## Native C++ SDK

This release moves to Ubuntu 24.04 and MinGW GCC 13 to match Native's C++ runtime ABI.

Image `1.2.0` includes [Native v1.1.0](https://github.com/wischner/native/releases/tag/v1.1.0)
for `windows-mingw-x86_64` in `/opt/native/windows-mingw-x86_64` (`$NATIVE_SDK`).
The release archive is SHA-256 pinned and includes `libnative.a`, public headers,
dependency libraries, `manifest.json`, licenses, and the `Native::Native` CMake target.
The image build compiles and links a consumer against this installed SDK.

Configure consumers with `-DNative_DIR="$NATIVE_SDK/lib/cmake/Native"`, then
use `find_package(Native CONFIG REQUIRED)` and link `Native::Native`.
Cross-compile with `-DCMAKE_TOOLCHAIN_FILE=/opt/toolchains/mingw-w64-x86_64.cmake`.
Deploy the SDK runtime DLLs with the application; WinUI applications require
Windows App Runtime 1.8 (x64) on the destination.
