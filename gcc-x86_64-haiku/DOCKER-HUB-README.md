# GCC x86_64 Haiku Cross-Toolchain

`wischner/gcc-x86_64-haiku` is a Docker image for **cross-compiling Haiku applications** from Linux to the `x86_64-unknown-haiku` target.

It includes a full Haiku-oriented cross-toolchain with sysroot, runtime libraries, development headers, and Jam, so it can build and link complete Haiku executables.

## What is included

- `x86_64-unknown-haiku-gcc` and `g++`
- Haiku-targeted binutils
- Haiku sysroot and runtime libraries
- Haiku development headers
- Haiku source tree for reference
- Jam build system
- build tools such as `git`, `python3`, `perl`, `cmake`, `make`, and `nasm`

## What this image is for

- cross-compiling Haiku applications from Linux
- C and C++ Haiku development
- Jam-based Haiku builds
- reproducible CI builds for Haiku targets

## Quick start

Interactive shell:

```bash
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-haiku:latest \
  bash
```

Compile a Haiku executable:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-haiku:latest \
  x86_64-unknown-haiku-gcc hello.c -o hello
```

Build with Jam:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-haiku:latest \
  jam
```

## Environment

- `HAIKU_TOOLCHAIN_PATH=/opt/haiku-buildtools`
- `HAIKU_SOURCE=/opt/haiku-buildtools/haiku`
- `HAIKU_SYSROOT=/opt/haiku-buildtools/build/cross-tools-x86_64/sysroot`

## Support

Issues and pull requests are welcome:
<https://github.com/wischner/docker-toolchains>
