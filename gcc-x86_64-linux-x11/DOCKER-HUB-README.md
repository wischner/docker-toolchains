# GCC x86_64 Linux X11 Toolchain

`wischner/gcc-x86_64-linux-x11` is a reusable Ubuntu 22.04 based Docker image for **native Linux desktop development with X11 and OpenGL**.

It is designed both as a practical end-user image for X11 projects and as the base image for the SDL desktop toolchain.

## What is included

- GCC and G++
- Autoconf, Automake, libtool, CMake, Make, and pkg-config
- GDB and Valgrind
- Git
- X11 development libraries
- original Athena widgets (libXaw 1.0.16), with ABI 6/7 shared and static
  libraries, headers, manuals, and pkg-config metadata
- Athena development dependencies, including X11/Xext, Xt, Xmu, and Xpm
- common X11 runtime tools
- Xephyr and Xvfb for nested/headless X11 integration tests
- X11 bitmap-font indexing tools
- Mesa OpenGL, GLU, EGL, and `mesa-utils`
- image libraries for PNG, JPEG, TIFF, WebP, and SVG
- image tools such as ImageMagick, Netpbm, Ghostscript, and librsvg
- font libraries such as FreeType and Fontconfig
- font tools and bundled fonts

## What this image is for

- native X11 application development
- OpenGL desktop applications on Linux
- image and font processing pipelines that target Linux desktop applications
- reusable desktop build environments in CI

## Quick start

Compile an X11 application:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-x11:latest \
  gcc -o app main.c $(pkg-config --cflags --libs x11 xft gl)
```

Compile an Athena widget application:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-x11:latest \
  gcc -o app main.c $(pkg-config --cflags --libs xaw)
```

Interactive shell:

```bash
docker run --rm -it \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-x11:latest \
  bash
```

## Running GUI applications

```bash
docker run --rm -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-x11:latest \
  ./app
```

## Related images

- `wischner/gcc-x86_64-linux-sdl` for SDL2 and SDL3 Linux desktop development

## Support

Issues and pull requests are welcome:
<https://github.com/wischner/docker-toolchains>
