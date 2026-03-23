# GCC x86_64 Linux Open Motif toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is

A reusable **Linux x86_64 Open Motif development base** on Ubuntu 22.04.
It extends the X11 toolchain with the core Open Motif development packages, the `uil` compiler, the Motif Window Manager, and GLw headers for Motif/OpenGL applications.

## Installed components

- Everything from **`gcc-x86_64-linux-x11`**
- **Open Motif** development files via `libmotif-dev`
- **UIL** compiler via `uil`
- **Motif Window Manager** via `mwm`
- Legacy X bitmap resources via `xbitmaps`
- Motif/OpenGL widget development headers via `libglw1-mesa-dev`

## Using this image as your compiler

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-motif:latest \
  gcc -o app main.c -lXm -lXt -lX11
```

Compile a UIL file:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-motif:latest \
  uil layout.uil -o layout.uid
```

## Running X11 and Motif applications

```bash
docker run --rm -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-motif:latest \
  ./app
```

## Relationship to other images

`wischner/gcc-x86_64-linux-motif` extends `wischner/gcc-x86_64-linux-x11` and is a sibling image to `wischner/gcc-x86_64-linux-sdl`.
