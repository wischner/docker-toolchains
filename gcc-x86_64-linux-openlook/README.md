# GCC x86_64 Linux OpenLook / XView toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is

A reusable **Linux x86_64 OpenLook and XView development base** on Ubuntu 22.04.
It extends the X11 toolchain by building the classic OpenLook desktop stack from source, including the XView toolkit, `olwm`, and `olvwm`.

## Installed components

- Everything from **`gcc-x86_64-linux-x11`**
- **XView** toolkit headers and libraries under `/usr/openwin`
- **OLGX** toolkit used by XView and OpenLook window managers
- **olwm** and **olvwm**
- XView clients, contrib examples, manuals, and installed example sources
- **SlingShot** source snapshot in `/usr/openwin/share/src/SlingShot` for optional manual builds
- X11 imake-era build tooling via `xutils-dev`

## Using this image as your compiler

Compile an XView application:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-openlook:latest \
  gcc -o app app.c -I/usr/openwin/include -I/usr/include/tirpc -L/usr/openwin/lib -Wl,-rpath,/usr/openwin/lib -lxview -lolgx -lX11 -lXext -lXmu -lXt -lXpm -ltirpc -lm -lutil
```

## Running OpenLook applications

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
