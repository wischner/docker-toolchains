# GCC x86_64 Linux OpenLook / XView Toolchain

`wischner/gcc-x86_64-linux-openlook` is a reusable Ubuntu 22.04 based Docker image for **native Linux desktop development with X11, OpenLook, and XView**.

It is designed for legacy OpenLook desktop software, XView applications, `olwm` and `olvwm` based environments, and projects that use the SlingShot XView extension library.

## What is included

- everything from `wischner/gcc-x86_64-linux-x11`
- XView toolkit headers and libraries
- OLGX toolkit libraries
- `olwm` and `olvwm`
- XView clients and contrib examples
- installed XView example sources and manuals
- SlingShot XView extension libraries and headers
- imake-era X11 build tools needed for classic OpenLook/XView projects

## What this image is for

- compiling XView applications on modern Linux
- maintaining classic OpenLook desktop software
- building software that expects `/usr/openwin`
- experimenting with `olwm` and `olvwm`
- building applications against the SlingShot XView extensions

## Quick start

Compile an XView application:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-openlook:latest \
  gcc -o app app.c -I/usr/openwin/include -I/usr/include/tirpc -L/usr/openwin/lib -Wl,-rpath,/usr/openwin/lib -lxview -lolgx -lX11 -lXext -lXmu -lXt -lXpm -ltirpc -lm -lutil
```

Compile an app that uses SlingShot:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-openlook:latest \
  gcc -o app app.c -I/usr/openwin/include -I/usr/include/tirpc -L/usr/openwin/lib -Wl,-rpath,/usr/openwin/lib -lsspkg -lxview -lolgx -lX11 -lXext -lXmu -lXt -lXpm -ltirpc -lm -lutil
```

Interactive shell:

```bash
docker run --rm -it \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-openlook:latest \
  bash
```

## Running GUI applications

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
