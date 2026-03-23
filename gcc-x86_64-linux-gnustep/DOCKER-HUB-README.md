# GCC x86_64 Linux GNUstep Toolchain

`wischner/gcc-x86_64-linux-gnustep` is a reusable Ubuntu 22.04 based Docker image for **native Linux desktop development with X11 and GNUstep**.

It is designed for GNUstep Foundation and AppKit projects, Objective-C and Objective-C++ applications, `gnustep-make` based builds, and classic GNUstep GUI workflows with Gorm and ProjectCenter.

## What is included

- everything from `wischner/gcc-x86_64-linux-x11`
- GNUstep development environment and build system
- Objective-C and Objective-C++ compiler support
- GNUstep Base and GUI development libraries
- the GNUstep cairo backend
- Gorm interface builder
- ProjectCenter IDE
- common GNUstep development frameworks such as Renaissance and Gorm development headers

## What this image is for

- compiling GNUstep Foundation command-line tools
- building GNUstep AppKit desktop applications
- compiling Objective-C and Objective-C++ code for GNUstep
- building projects that use `gnustep-make`
- working with Gorm and ProjectCenter in a containerized GNUstep environment

## Quick start

Compile a Foundation tool:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-gnustep:latest \
  bash -lc '. /usr/share/GNUstep/Makefiles/GNUstep.sh && gcc -o hello hello.m $(gnustep-config --objc-flags) $(gnustep-config --base-libs)'
```

Compile a GUI app:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-gnustep:latest \
  bash -lc '. /usr/share/GNUstep/Makefiles/GNUstep.sh && gcc -o app app.m $(gnustep-config --objc-flags) $(gnustep-config --gui-libs)'
```

Build with `gnustep-make`:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-gnustep:latest \
  bash -lc '. /usr/share/GNUstep/Makefiles/GNUstep.sh && make'
```

Interactive shell:

```bash
docker run --rm -it \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-gnustep:latest \
  bash -l
```

## Running GUI applications

```bash
docker run --rm -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-gnustep:latest \
  bash -lc '. /usr/share/GNUstep/Makefiles/GNUstep.sh && ./app'
```

## Related images

- `wischner/gcc-x86_64-linux-x11` for the general X11/OpenGL Linux desktop base
- `wischner/gcc-x86_64-linux-motif` for Open Motif based X11 development
- `wischner/gcc-x86_64-linux-sdl` for SDL2 and SDL3 Linux desktop development

## Support

Issues and pull requests are welcome:
<https://github.com/wischner/docker-toolchains>
