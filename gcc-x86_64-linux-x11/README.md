# GCC x86_64 Linux X11 toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is

A reusable **Linux x86_64 X11 development base** on Ubuntu 22.04.
It is intended for native X11/OpenGL development and also serves as the base image for the SDL2 toolchain.

## Installed components

- **GCC / G++** (Ubuntu 22.04 default toolchain)
- **Autoconf**, **Automake**, **libtool**, **CMake**, **Make**, **pkg-config**
- **GDB** and **Valgrind**
- **Git**
- **X11** development libraries and common X11 runtime tools
- Original **Athena Widget Set (libXaw 1.0.16)** built from source, including
  ABI 6/7 shared and static libraries, public/private headers, manuals, and
  `xaw`, `xaw6`, and `xaw7` pkg-config metadata
- Athena development dependencies: X11/Xext protocols and libraries, Xt,
  **Xmu** (`libxmu-dev`), and Xpm
- **Xephyr** and **Xvfb** for nested/headless X11 integration tests
- X11 bitmap-font indexing tools (`mkfontdir`, `mkfontscale`)
- **OpenGL** (Mesa), GLU, EGL, and `mesa-utils`
- Image development libraries: libpng, libjpeg, libtiff, libwebp, librsvg
- Image tools: **ImageMagick**, **Netpbm**, **librsvg2-bin**, **Ghostscript**
- Font/text libraries: **FreeType**, **Fontconfig**
- Font tools and sample fonts: **fonttools**, DejaVu, FreeFont

## Using this image as your compiler

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-x11:latest \
  gcc -o app main.c $(pkg-config --cflags --libs x11 xft gl)
```

Compile an Athena widget application against the current ABI:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-x11:latest \
  gcc -o app main.c $(pkg-config --cflags --libs xaw)
```

## Running X11 applications

```bash
docker run --rm -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-x11:latest \
  ./app
```

## Building the image

The source snapshot is bundled at `packages/libXaw-1.0.16.tar.xz`, so normal
builds require neither the original checkout nor network access:

```bash
make build-gcc-x86_64-linux-x11
```

To explicitly refresh the bundled archive from the original local checkout:

```bash
make -C gcc-x86_64-linux-x11 -f Makefile.toolchain refresh-libxaw
```

To refresh it from another checkout:

```bash
make -C gcc-x86_64-linux-x11 -f Makefile.toolchain \
  refresh-libxaw LIBXAW_ROOT=/path/to/libxaw
```

## Relationship to SDL2 image

`wischner/gcc-x86_64-linux-sdl` extends this image and adds SDL2, SDL2_image, SDL2_mixer, SDL2_ttf, SDL3, audio backends, and Wayland-related packages.
