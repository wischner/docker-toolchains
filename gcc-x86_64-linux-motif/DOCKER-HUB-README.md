# GCC x86_64 Linux Open Motif Toolchain

`wischner/gcc-x86_64-linux-motif` is a reusable Ubuntu 22.04 based Docker image for **native Linux desktop development with X11 and Open Motif**.

It is designed for legacy Motif applications, UIL-based workflows, and Motif/OpenGL desktop software that still targets classic X11 environments.

## What is included

- everything from `wischner/gcc-x86_64-linux-x11`
- Open Motif development files
- the `uil` User Interface Language compiler
- the `mwm` Motif Window Manager
- legacy X bitmap resources
- GLw headers for Motif/OpenGL widgets

## What this image is for

- native Open Motif application development
- compiling Motif projects that link against `libXm`
- building UIL resource files with `uil`
- maintaining legacy X11 desktop software on Linux
- Motif applications that also use OpenGL/GLw widgets

## Quick start

Compile a Motif application:

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

Interactive shell:

```bash
docker run --rm -it \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-motif:latest \
  bash
```

## Running GUI applications

```bash
docker run --rm -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-motif:latest \
  ./app
```

## Related images

- `wischner/gcc-x86_64-linux-x11` for the general X11/OpenGL Linux desktop base
- `wischner/gcc-x86_64-linux-sdl` for SDL2 and SDL3 Linux desktop development

## Support

Issues and pull requests are welcome:
<https://github.com/wischner/docker-toolchains>
