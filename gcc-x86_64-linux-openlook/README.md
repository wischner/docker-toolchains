# GCC x86_64 Linux OpenLook / XView toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is

A reusable **Linux x86_64 OpenLook and XView development base** on Ubuntu 22.04.
It extends the X11 toolchain with the CMake-native
[`retro-vault/open-look`](https://github.com/retro-vault/open-look) SDK.

## Installed components

- Everything from **`gcc-x86_64-linux-x11`**
- Shared and static **XView** libraries (`libxview.so` and `libxview.a`)
- Shared and static **OLGX** libraries (`libolgx.so` and `libolgx.a`)
- Every exported header from `include/olgx`, `include/pixrect`,
  `include/xview`, and `include/xview_private`
- `olwm` plus the complete OpenLook application set from the source tree
- Runtime fonts, images, bitmaps, menus, locales, and manuals
- `pkg-config` modules for `xview` and `olgx`
- CMake targets `OpenLook::xview`, `OpenLook::xview_static`,
  `OpenLook::olgx`, and `OpenLook::olgx_static`
- `openlook-xephyr`, a self-contained nested/headless OpenLook test session

## Using this image as your compiler

Compile an XView application:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-openlook:latest \
  bash -lc 'gcc -o app app.c $(pkg-config --cflags --libs xview)'
```

CMake projects can use:

```cmake
find_package(OpenLook CONFIG REQUIRED)
target_link_libraries(my_app PRIVATE OpenLook::xview)
```

## Running OpenLook applications

Run an application in a self-contained Xephyr session. If the container has no
parent X display, the helper automatically supplies one with Xvfb:

```bash
docker run --rm \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-openlook:latest \
  openlook-xephyr ./app
```

To use an existing host X server instead:

```bash
docker run --rm -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-openlook:latest \
  ./app
```

## Relationship to other images

`wischner/gcc-x86_64-linux-openlook` extends `wischner/gcc-x86_64-linux-x11` and complements the Motif and GNUstep images for another classic Unix desktop toolkit family.
