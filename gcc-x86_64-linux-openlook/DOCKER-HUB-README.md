# GCC x86_64 Linux OpenLook / XView Toolchain

`wischner/gcc-x86_64-linux-openlook` is a reusable Ubuntu 22.04 based Docker image for **native Linux desktop development with X11, OpenLook, and XView**.

It is designed for legacy OpenLook desktop software, XView applications, and
`olwm` environments using the CMake-native `retro-vault/open-look` port.

## What is included

- everything from `wischner/gcc-x86_64-linux-x11`
- shared and static XView and OLGX libraries
- every exported `olgx`, `pixrect`, `xview`, and `xview_private` header
- `olwm` and the complete OpenLook application suite
- runtime fonts, images, bitmaps, menus, locales, and manuals
- `pkg-config` modules and CMake imported targets for shared/static linking
- `openlook-xephyr` for self-contained nested/headless OpenLook GUI tests

## What this image is for

- compiling XView applications on modern Linux
- maintaining classic OpenLook desktop software
- building software that expects `/usr/openwin`
- testing applications under `olwm` and Xephyr

## Quick start

Compile an XView application:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-openlook:latest \
  bash -lc 'gcc -o app app.c $(pkg-config --cflags --libs xview)'
```

CMake projects can call `find_package(OpenLook CONFIG REQUIRED)` and link
`OpenLook::xview` (or the supplied static targets).

Interactive shell:

```bash
docker run --rm -it \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-openlook:latest \
  bash
```

## Running GUI applications

Self-contained Xephyr session (also works headlessly through Xvfb):

```bash
docker run --rm \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-openlook:latest \
  openlook-xephyr ./app
```

Existing host X server:

```bash
docker run --rm -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-openlook:latest \
  ./app
```

## Related images

- `wischner/gcc-x86_64-linux-x11` for the general X11/OpenGL Linux desktop base
- `wischner/gcc-x86_64-linux-motif` for Open Motif based X11 development
- `wischner/gcc-x86_64-linux-gnustep` for GNUstep based desktop development

## Support

Issues and pull requests are welcome:
<https://github.com/wischner/docker-toolchains>
