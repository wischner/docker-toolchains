# GCC x86_64 GEMix toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is

A reusable **Linux x86_64 GEMix development base** on Ubuntu 22.04.
It extends the X11 toolchain with the GEM SDK — shared libraries, headers,
runtime resources, and tools — built from a pinned GEM release.

Current image version: `1.2.0`. GEM version: `v1.0.0`.

## Installed components

- Everything from **`gcc-x86_64-linux-x11`**
- GEMix shared libraries in `/usr/local/lib`:
  `libaes.so`, `libvdi.so`, `librasta.so`, `libplatform_linux.so`, `libgem.so`
- GEMix headers in `/usr/local/include`: `gem.h`, `gem/` (`aes.h`, `gem.h`,
  `gemd.h`, `os.h`, `portab.h`, `vdi.h`), and `platform/os.h`
- GEMix fonts and runtime resources in `/opt/gemix/share/gem`
- GEM tools in `/opt/gemix/bin`: `gemd` (display server) and `resgen`
  (resource compiler)
- pkg-config files in `/usr/local/lib/pkgconfig`:
  `gemix.pc`, `gemix-aes.pc`, `gemix-vdi.pc`, `gemix-rasta.pc`,
  `gemix-platform-linux.pc`, `gemix-gem.pc`

The image sets `GEM_RESOURCE_DIR=/opt/gemix/share/gem`, so GEMix programs can
use the bundled fonts, cursor resources, and alert icons without mounting a
separate runtime directory.

## Using this image as your compiler

Compile with the umbrella package:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-gemix:latest \
  bash -lc 'gcc -o app main.c $(pkg-config --cflags --libs gemix)'
```

Compile when you also need the Linux platform helpers directly:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-gemix:latest \
  bash -lc 'gcc -o app main.c $(pkg-config --cflags --libs gemix gemix-platform-linux)'
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

## Versioning and pinned sources

The GEM SDK is compiled from source during the image build. `GEM_REF` selects
the release tag and `GEM_COMMIT` is verified against the resolved clone, so the
layer is reproducible rather than following a moving branch. Both live in
`build.args`.

The SDK is built rather than copied from a prebuilt upstream tree on purpose.
GEM's own staged SDK is linked against its build host's glibc (2.38) and, in
debug configurations, against `libasan.so.8`. This base is Ubuntu 22.04 with
glibc 2.35 and `libasan.so.6`, so those binaries will not load here. The
release configuration built in the image links no sanitizer runtime, so
consumers are not forced to link one either.

The resolved revision, tag, and source URL are recorded in the image:

```text
/opt/gemix/share/metadata/gem.version
/opt/gemix/share/metadata/gem.ref
/opt/gemix/share/metadata/gem.source
```

`IMG_VERSION` versions the image and moves independently of the GEM release it
carries. `BASE_IMAGE` pins the X11 base image tag.

## Relationship to other images

`wischner/gcc-x86_64-gemix` extends `wischner/gcc-x86_64-linux-x11` and adds the
hosted GEM SDK on top of the general Linux GUI development base.
