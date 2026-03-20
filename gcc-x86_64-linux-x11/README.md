# GCC x86_64 Linux X11 toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is

A reusable **Linux x86_64 X11 development base** on Ubuntu 22.04.
It is intended for native X11/OpenGL development and also serves as the base image for the SDL2 toolchain.

## Installed components

- **GCC / G++** (Ubuntu 22.04 default toolchain)
- **CMake**, **Make**, **pkg-config**
- **GDB** and **Valgrind**
- **Git**
- **X11** development libraries and common X11 runtime tools
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

## Running X11 applications

```bash
docker run --rm -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-x11:latest \
  ./app
```

## Relationship to SDL2 image

`wischner/gcc-x86_64-linux-sdl` extends this image and adds SDL2, SDL2_image, SDL2_mixer, SDL2_ttf, SDL3, audio backends, and Wayland-related packages.
