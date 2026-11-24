# GCC x86_64 Linux OpenLook / XView Toolchain

**Support:** [wischner.co.uk/support](https://wischner.co.uk/support)

`wischner/gcc-x86_64-linux-openlook` is a reusable Ubuntu 22.04 based Docker image for **native Linux desktop development with X11, OpenLook, and XView**.

It is designed for legacy OpenLook desktop software, XView applications, and
`olwm` environments using the CMake-native `retro-vault/open-look` port.

Version **1.5.0** includes [OpenLook v0.5.0](https://github.com/retro-vault/open-look/releases/tag/v0.5.0),
pinned to commit `4af207984537f7f895ca06616ef07c1d79236694`.
The SDK and runtime use `/usr/openwin`; configuration lives in `/etc/openlook`
and runtime assets in `/usr/openwin/share/openlook`.

## What is included

- everything from `wischner/gcc-x86_64-linux-x11`
- shared and static XView and OLGX libraries
- every exported `olgx`, `pixrect`, `xview`, and `xview_private` header
- `olwm` and the OpenLook application suite, including File Manager,
  MosaiX with its private CEF runtime, Calculator (`xcalc`), and Virtual Desktops (`vwm`)
- runtime fonts, images, bitmaps, menus, File Manager help, locales,
  manuals, and the `sun-cmd` terminfo entry
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

The installed environment helper is `/usr/openwin/share/openlook/environment.sh`.
MosaiX may require `-e MOSAIX_DISABLE_SANDBOX=1` with Docker's default seccomp
policy; use that option only for trusted development content because it disables
Chromium's process sandbox.

In v0.5.0, several applications crash during SIGTERM cleanup. Close applications
through the window manager for a normal shutdown.

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

## CONTRIBUTE

Contributions are welcome. Please open an issue or pull request:
<https://github.com/wischner/docker-toolchains>

## Native C++ SDK

Image `1.5.0` includes [Native v1.1.0](https://github.com/wischner/native/releases/tag/v1.1.0)
for `linux-openlook-x86_64` in `/opt/native/linux-openlook-x86_64` (`$NATIVE_SDK`).
The release archive is SHA-256 pinned and includes `libnative.a`, public headers,
dependency libraries, `manifest.json`, licenses, and the `Native::Native` CMake target.
The image build compiles and links a consumer against this installed SDK.

Configure consumers with `-DNative_DIR="$NATIVE_SDK/lib/cmake/Native"`, then
use `find_package(Native CONFIG REQUIRED)` and link `Native::Native`.
