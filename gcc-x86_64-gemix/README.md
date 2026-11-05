# GCC x86_64 GEMix toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is

A reusable **Linux x86_64 GEMix development base** on Ubuntu 22.04.
It extends the X11 toolchain with the GEM SDK, the bundled GEM programs, and
the Rasta viewer, built from a pinned GEM revision.

Current image version: `1.4.1`.
GEM revision: `03a9c1efdc67fef89abb9c1c3c5de9d42f133ecf`.
Rasta revision: `5f1e1511e918e8b4dfa6f8b7a51272f66133ea0e`, the snapshot that
revision of GEM builds.

## Installed components

- Everything from **`gcc-x86_64-linux-x11`**, plus SDL2 for the Rasta viewer
- GEMix shared libraries in `/usr/local/lib` and `/opt/gemix/sdk/lib`:
  `libaes.so`, `libvdi.so`, `librasta.so`, `libplatform_linux.so`, `libgem.so`,
  `libfat12.so`, `libmsa.so`, `libprg.so`
- GEMix static libraries in the same directories:
  `libgemconf.a`, `libgemctl.a`, `libstout.a`, and `libmusashi.a`
- GEMix headers in `/usr/local/include` and `/opt/gemix/sdk/include`:
  `gem.h`, `gem/`, `platform/os.h`, `stout/disk.h`, `fat12/`, `msa/`, and `prg/`
- GEMix fonts and runtime resources in `/opt/gemix/share/gem`
- Sample resources in `/opt/gemix/samples/data`: desktop icons, clock numbers,
  and the Gemscape toolbar
- Programs on `PATH`:
  `rasta`, `gemd`, `desktop`, `terminal`, `calc`, `clock`, `stout`, `gemread`,
  `gemscape`, their `*_hosted` variants, `resgen`, and `gem-desktop`
- pkg-config files in `/usr/local/lib/pkgconfig`:
  `gemix`, `gemix-aes`, `gemix-vdi`, `gemix-rasta`, `gemix-platform-linux`,
  `gemix-gem`, `gemix-gemconf`, `gemix-gemctl`, `gemix-fat12`, `gemix-msa`,
  `gemix-prg`, `gemix-stout`, and `gemix-musashi`

The image sets `GEM_RESOURCE_DIR=/opt/gemix/share/gem` and
`GEM_SAMPLE_DATA=/opt/gemix/samples/data`. The upstream SDK tree is
`/opt/gemix/sdk`. Gemscape keeps its CEF runtime at the path compiled into
the binary, `/opt/gemix/work/deps/cef/source`. Gemread is AGPL-3.0-or-later;
the rest of the bundled GEM core is MIT.

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

## Running GEM

`gem-desktop` starts Rasta, waits for it, starts `gemd`, and then starts the
desktop. Pass the host display into the container:

```bash
docker run --rm -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  wischner/gcc-x86_64-gemix:latest \
  gem-desktop
```

The same programs can be started separately. Rasta uses UDP port 5000.
`GEM_RASTA_PORT` selects another port for both the viewer and GEM.

```bash
docker run --rm -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  wischner/gcc-x86_64-gemix:latest \
  rasta --inverse off --cursor off --bpp 32 --port 5000
```

`desktop`, `terminal`, `calc`, `clock`, `stout`, `gemread`, and `gemscape`
are the gemd clients. The `*_hosted` binaries link AES and VDI directly and
need their own Rasta session.

## Versioning and pinned sources

The GEM SDK, bundled programs, and Rasta viewer are compiled from source
during the image build. `GEM_REF` and `GEM_COMMIT` select the GEM revision.
The build fetches that commit and checks the resolved tree, so the layer does
not follow a moving branch. Rasta's revision is the one pinned by that GEM
tree. Both values live in `build.args`.

The SDK is built rather than copied from a prebuilt upstream tree on purpose.
GEM's own staged SDK is linked against its build host's glibc. This base is
Ubuntu 22.04, so those binaries will not load here. The release configuration
built in the image links no sanitizer runtime.

The resolved revisions are recorded in the image:

```text
/opt/gemix/share/metadata/gem.version
/opt/gemix/share/metadata/gem.ref
/opt/gemix/share/metadata/gem.source
/opt/gemix/share/metadata/rasta.version
/opt/gemix/share/metadata/rasta.source
```

`IMG_VERSION` versions the image and moves independently of the GEM revision
it carries. `BASE_IMAGE` pins the X11 base image tag.

## Relationship to other images

`wischner/gcc-x86_64-gemix` extends `wischner/gcc-x86_64-linux-x11` and adds
the hosted GEM SDK, the bundled GEM programs, and the Rasta viewer.
