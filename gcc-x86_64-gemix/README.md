# GCC x86_64 GEMix toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is

A reusable **Linux x86_64 GEMix development base** on Ubuntu 22.04.
It extends the X11 toolchain with the GEM SDK, the Native C++ SDK for
GEMix, the bundled GEM programs, and the Rasta viewer, built from pinned GEM
and Native revisions.

Current image version: `1.5.1`.
GEM main snapshot: `6e6c60610ac46bf4586ab44da8de20d5eb41a83c`.
Native master snapshot: `d560a3a7be6348a772ec8c1f4110b966bd00a61d`
(SDK package version `v0.0.0`).
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
- Native C++ UI SDK for GEMix, both backends, in `/opt/gemix/native`:
  `hosted` (AES/VDI in-process, drawing straight to Rasta) and `gemd`
  (a client of a running `gemd` through `libgem`). Each holds the public
  `native.h` / `native/` headers, `libnative.a`, its link dependencies, a
  relocatable CMake package (`lib/cmake/Native`), `manifest.json`, and
  third-party notices in `share/licenses`
- Programs on `PATH`:
  `rasta`, `gemd`, `desktop`, `terminal`, `calc`, `clock`, `stout`, `gemread`,
  `gemscape`, `ted`, their `*_hosted` variants, `resgen`, and `gem-desktop`
- pkg-config files in `/usr/local/lib/pkgconfig`:
  `gemix`, `gemix-aes`, `gemix-vdi`, `gemix-rasta`, `gemix-platform-linux`,
  `gemix-gem`, `gemix-gemconf`, `gemix-gemctl`, `gemix-fat12`, `gemix-msa`,
  `gemix-prg`, `gemix-stout`, and `gemix-musashi`, plus `native-gemix`
  (hosted) and `native-gemix-gemd` for the Native SDK

The image sets `GEM_RESOURCE_DIR=/opt/gemix/share/gem`,
`GEM_SAMPLE_DATA=/opt/gemix/samples/data`,
`NATIVE_GEMIX_SDK=/opt/gemix/native/hosted`, and
`NATIVE_GEMIX_GEMD_SDK=/opt/gemix/native/gemd`. The upstream SDK tree is
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

Build a Native application with CMake. Pick the backend with
`CMAKE_PREFIX_PATH`:

```cmake
cmake_minimum_required(VERSION 3.20)
project(app LANGUAGES CXX)
find_package(Native CONFIG REQUIRED)
add_executable(app main.cpp)
target_link_libraries(app PRIVATE Native::Native)
```

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-gemix:latest \
  bash -lc 'cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_PREFIX_PATH="$NATIVE_GEMIX_GEMD_SDK" &&
            cmake --build build'
```

Or with pkg-config:

```bash
g++ -o app main.cpp $(pkg-config --cflags --libs native-gemix-gemd)
```

A Native program defines `int program(int, char **)` instead of `main`.
The `gemd` build runs as a client of `gemd` like the bundled programs; the
hosted build (`$NATIVE_GEMIX_SDK`, `native-gemix`) needs its own Rasta session.

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

`desktop`, `terminal`, `calc`, `clock`, `stout`, `gemread`, `gemscape`, and
`ted` are the gemd clients. The `*_hosted` binaries link AES and VDI directly and
need their own Rasta session.

## Versioning and pinned sources

The GEM SDK, bundled programs, and Rasta viewer are compiled from source
during the image build. `GEM_REF` and `GEM_COMMIT` select the GEM revision.
The build fetches that commit and checks the resolved tree, so the layer does
not follow a moving branch. Rasta's revision is the one pinned by that GEM
tree. `NATIVE_REF` and `NATIVE_COMMIT` select the Native revision the same
way. All values live in `build.args`.

The Native SDKs are built in the image with Native's own release packager,
against the GEM built just before them. Native's published GEMix archives
carry the GEM libraries of whatever image built them, which would not match
the GEM release here.

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
/opt/gemix/share/metadata/native.version
/opt/gemix/share/metadata/native.ref
/opt/gemix/share/metadata/native.source
```

`IMG_VERSION` versions the image and moves independently of the GEM revision
it carries. `BASE_IMAGE` pins the X11 base image tag.

## Relationship to other images

`wischner/gcc-x86_64-gemix` extends `wischner/gcc-x86_64-linux-x11` and adds
the hosted GEM SDK, the Native SDK for GEMix, the bundled GEM programs, and
the Rasta viewer.

## Complete menus and protocol compatibility

Version 1.5.1 includes matching protocol-3 libgem/gemd and the Native menu
installation fix. Standard GEM menus support 256 objects and 256 strings,
including separators; labels over 63 bytes and malformed or oversized trees
are rejected rather than truncated. Failed Native installation retains the
previous menu and reports the status. Rebuild clients and restart gemd and
all clients together: protocol-2 binaries cannot use the new server.

The image build runs a real-server smoke test for 32, 33 and 49 strings,
65 and 256 objects, check/disable updates, removal and overflow rejection.
Both bundled Native SDK variants are rebuilt against the same GEM libraries.
The Native revision is a master snapshot, packaged as v0.0.0 using Native's
existing snapshot convention; the exact commit is recorded in metadata.

The Native pkg-config entries include `libgemctl`, which supplies the current
chrome metrics. The gemd variant resolves its AES calls through `libgem`; it
does not pull the direct AES/VDI implementation into client applications.
Both pkg-config and relocated CMake consumers are linked during image builds.

GEM tab bands default to 20 pixels. Native applications can use
`tab_view::set_tab_height(28)` for a per-control override, or pass
`std::nullopt` to restore the theme.
