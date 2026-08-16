# GCC x86_64 Linux Window Maker / WINGs toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is

A complete Ubuntu 22.04 native development environment for **Window Maker**
and its **WINGs** widget toolkit. It extends `gcc-x86_64-linux-x11`, builds the
CMake-native [`retro-vault/window-maker`](https://github.com/retro-vault/window-maker)
source at a pinned revision, and retains the patched checkout at
`/usr/local/src/window-maker`.

## Installed components

- Everything from **`gcc-x86_64-linux-x11`**
- Shared and static `WINGs`, `WUtil`, `wraster`, and `WMaker` libraries
- Public `WINGs.h`, `WUtil.h`, `WINGsP.h`, `wraster.h`, and `WMaker.h` headers
- `pkg-config` modules for shared and explicit static linking
- CMake targets for every shared and static library
- Window Maker, WPrefs, wmagnify, wmiv, and the full companion tool set
- WINGs, wraster, and wmlib example/test executables
- Menus, styles, themes, icons, WINGs/WPrefs artwork, defaults, translations,
  desktop session metadata, and manuals
- Full PNG, JPEG, TIFF, GIF, WebP, XPM, and ImageMagick image support
- Xft/fontconfig and Pango text support, EXIF, RandR, XRes, Xinerama, Shape,
  and shared-memory X extensions
- Gettext, Perl, Python, xterm, Xvfb, Xephyr, and X11 runtime utilities
- `window-maker-xephyr`, a self-contained nested/headless development session

## Compile a WINGs application

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-window-maker:latest \
  bash -lc 'gcc -o app app.c $(pkg-config --cflags --libs WINGs)'
```

Use `WINGs-static`, `WUtil-static`, `wrlib-static`, or `wmlib-static` when a
Window Maker SDK archive must be linked statically. System libraries remain
dynamically linked.

CMake projects can use:

```cmake
find_package(WindowMaker CONFIG REQUIRED)
target_link_libraries(app PRIVATE WindowMaker::WINGs)

# Static Window Maker SDK libraries:
target_link_libraries(static_app PRIVATE WindowMaker::WINGs_static)
```

Available targets are `WindowMaker::WINGs`, `WindowMaker::WUtil`,
`WindowMaker::wraster`, `WindowMaker::WMaker`, and matching `_static` targets.

## Build the retained Window Maker source

The image contains the exact patched checkout used to create the installed
SDK:

```bash
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-window-maker:latest \
  bash

cmake -S "$WINDOW_MAKER_SOURCE" -B /work/build \
  -DWMAKER_DEV_TREE=OFF \
  -DCMAKE_INSTALL_PREFIX=/work/stage \
  -DWMAKER_RANDR=ON -DWMAKER_PANGO=ON -DWMAKER_MAGICK=ON
cmake --build /work/build -j"$(nproc)"
```

## Run applications under Window Maker

The helper starts Xvfb when necessary, creates a nested Xephyr server, makes a
private Window Maker user configuration, starts `wmaker`, and runs the command:

```bash
docker run --rm \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-window-maker:latest \
  window-maker-xephyr ./app
```

To use the host display directly:

```bash
docker run --rm -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-window-maker:latest \
  ./app
```

## Relationship to other images

`wischner/gcc-x86_64-linux-window-maker` extends the general X11 image and
complements the OpenLook, Open Motif, and GNUstep desktop development images.

