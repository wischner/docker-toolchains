# GCC x86_64 GEMix toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is

A reusable **Linux x86_64 GEMix development base** on Ubuntu 22.04.
It extends the X11 toolchain with the current GEMix shared libraries and headers staged from the local Triglav OS GEM tree.

## Installed components

- Everything from **`gcc-x86_64-linux-x11`**
- GEMix shared libraries in `/usr/local/lib`:
  `libaes.so`, `libvdi.so`, `libplatform_linux.so`, `librasta.so`
- GEMix headers in `/usr/local/include`
- pkg-config files in `/usr/local/lib/pkgconfig`:
  `gemix.pc`, `gemix-aes.pc`, `gemix-vdi.pc`, `gemix-rasta.pc`, `gemix-platform-linux.pc`

## Using this image as your compiler

Compile with the umbrella package:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-gemix:latest \
  gcc -o app main.c $(pkg-config --cflags --libs gemix)
```

Compile when you also need the Linux platform helpers directly:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-gemix:latest \
  gcc -o app main.c $(pkg-config --cflags --libs gemix gemix-platform-linux)
```

## Running GEMix applications

```bash
docker run --rm -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-gemix:latest \
  ./app
```

## Relationship to other images

`wischner/gcc-x86_64-gemix` extends `wischner/gcc-x86_64-linux-x11` and adds the hosted GEMix SDK on top of the general Linux GUI development base.
