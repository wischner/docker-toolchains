# GCC x86_64 Linux GNUstep toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is

A reusable **Linux x86_64 GNUstep development base** on Ubuntu 22.04.
It extends the X11 toolchain with GNUstep Base and GUI development libraries, the GNUstep build system, Objective-C and Objective-C++ compilers, the cairo backend, and the classic GNUstep developer tools.

## Installed components

- Everything from **`gcc-x86_64-linux-x11`**
- **GNUstep** development environment via `gnustep-devel`
- **GNUstep build system** via `gnustep-make`
- **Objective-C** and **Objective-C++** compiler support via `gobjc` and `gobjc++`
- **GNUstep Base** and **GUI** development libraries
- **GNUstep cairo backend** via `gnustep-back0.29-cairo`
- **Gorm** interface builder and **ProjectCenter** IDE
- Common GNUstep development frameworks: **libgorm-dev**, **librenaissance0-dev**

## Using this image as your compiler

Compile a Foundation tool:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-gnustep:latest \
  bash -lc '. /usr/share/GNUstep/Makefiles/GNUstep.sh && gcc -o hello hello.m $(gnustep-config --objc-flags) $(gnustep-config --base-libs)'
```

Compile an AppKit GUI app:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-gnustep:latest \
  bash -lc '. /usr/share/GNUstep/Makefiles/GNUstep.sh && gcc -o app app.m $(gnustep-config --objc-flags) $(gnustep-config --gui-libs)'
```

Build a GNUstep project with `gnustep-make`:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-gnustep:latest \
  bash -lc '. /usr/share/GNUstep/Makefiles/GNUstep.sh && make'
```

For an interactive GNUstep-aware shell, start `bash -l`.

## Running GNUstep applications

```bash
docker run --rm -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-gnustep:latest \
  bash -lc '. /usr/share/GNUstep/Makefiles/GNUstep.sh && ./app'
```

## Relationship to other images

`wischner/gcc-x86_64-linux-gnustep` extends `wischner/gcc-x86_64-linux-x11` and complements `wischner/gcc-x86_64-linux-motif` for a different legacy desktop toolkit and application framework.
