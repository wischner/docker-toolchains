# GCC x86_64 Linux Open Motif toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is

A reusable **Linux x86_64 Open Motif development base** on Ubuntu 22.04.
It extends the X11 toolchain with the complete Open Motif SDK, the `uil`
compiler, the Motif Window Manager, GLw, the full CDE 2.5.3 desktop, and
self-contained nested-X testing.

## Installed components

- Everything from **`gcc-x86_64-linux-x11`**
- **Open Motif** development files via `libmotif-dev`
- Shared and static **Xm**, **Mrm**, and **Uil** libraries
- **UIL** compiler via `uil`
- **Motif Window Manager** via `mwm`
- Legacy X bitmap resources via `xbitmaps`
- Shared and static Motif/OpenGL widgets via `libglw1-mesa-dev`
- `pkg-config` modules for shared and static Motif components
- CMake imported targets for shared and static Motif components
- **Xvfb**, **Xephyr**, and the `motif-xephyr` test-session helper
- **CDE 2.5.3** from [`retro-vault/cde`](https://github.com/retro-vault/cde),
  installed at `/usr/dt`: desktop and window manager, login and session
  tools, file manager, terminal, editor, mail, calendar, utilities,
  Application Builder, Information Manager, Desktop KornShell, and online
  help in English, German, Spanish, French, Italian, and Japanese
- CDE development headers and shared libraries under `/usr/dt/include` and
  `/usr/dt/lib`
- `cde-xephyr`, a self-contained nested CDE session with `rpcbind`,
  ToolTalk, and the calendar service

## Using this image as your compiler

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-motif:latest \
  bash -lc 'gcc -o app main.c $(pkg-config --cflags --libs xm)'
```

Static Motif archives, with their transitive link dependencies, are exposed
through `xm-static`, `mrm-static`, `uil-static`, `glw-static`, and
`motif-static`.

For CMake projects:

```cmake
find_package(Motif CONFIG REQUIRED)
target_link_libraries(app PRIVATE Motif::Xm)

# Available when a static Motif component is required:
target_link_libraries(static_app PRIVATE Motif::Xm_static)
```

Other targets are `Motif::Mrm`, `Motif::Uil`, `Motif::GLw`,
`Motif::Motif`, and corresponding `_static` targets.

Compile a CDE application:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-motif:latest \
  bash -lc 'gcc -o app main.c -I/usr/dt/include -L/usr/dt/lib -lDtSvc -lXm -lXt -lX11'
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

For a self-contained nested test session, including a headless Xvfb parent
when the host has no usable display:

```bash
docker run --rm \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-motif:latest \
  motif-xephyr ./app
```

Start the CDE desktop in a nested Xephyr window. This needs to run as root
inside the container so it can start `rpcbind`:

```bash
docker run --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$HOME/.Xauthority":/root/.Xauthority:ro \
  wischner/gcc-x86_64-linux-motif:latest \
  cde-xephyr
```

`CDE_SCREEN` selects the initial window size. The default is `1280x800`.

To use the host display directly:

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
