# GCC x86_64 Linux SDL Toolchain

**Support:** [wischner.co.uk/support](https://wischner.co.uk/support)

`wischner/gcc-x86_64-linux-sdl` is a ready-to-use Ubuntu 22.04 Docker image for **SDL-based Linux desktop development**.

It combines the standard GCC/CMake toolchain with X11, Mesa/OpenGL, SDL2, SDL2_image, SDL2_mixer, SDL2_ttf, and SDL3 so you can build modern Linux game and multimedia projects in a reproducible environment.

## What is included

- GCC and G++
- CMake, Make, and pkg-config
- GDB and Valgrind
- Git
- SDL2, SDL2_image, SDL2_mixer, SDL2_ttf
- SDL3
- X11 development libraries and tools
- Mesa OpenGL, GLU, and EGL
- Wayland and xkbcommon
- image codec libraries such as PNG, JPEG, TIFF, and WebP
- audio codec libraries such as Vorbis, Ogg, FLAC, MPG123, and Opus
- PulseAudio and ALSA development libraries

## What this image is for

- SDL2 game development
- SDL3 game development
- Linux multimedia applications
- CI builds for Linux desktop projects
- OpenGL-based SDL applications

## Quick start

Compile an SDL2 application:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-sdl:latest \
  bash -lc 'gcc -o game main.c $(pkg-config --cflags --libs sdl2 SDL2_image SDL2_mixer SDL2_ttf gl)'
```

Compile an SDL3 application:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-sdl:latest \
  bash -lc 'gcc -o game3 main.c $(pkg-config --cflags --libs sdl3)'
```

Interactive shell:

```bash
docker run --rm -it \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-sdl:latest \
  bash
```

## Running GUI applications

To run an SDL application against your host X11 display:

```bash
docker run --rm -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-sdl:latest \
  ./build/game
```

## Related images

- `wischner/gcc-x86_64-linux-x11` for a non-SDL Linux desktop/X11 base image

## CONTRIBUTE

Contributions are welcome. Please open an issue or pull request:
<https://github.com/wischner/docker-toolchains>

## Native C++ SDK

Image `1.4.0` includes [Native v1.1.0](https://github.com/wischner/native/releases/tag/v1.1.0)
for `linux-sdl2-x86_64` in `/opt/native/linux-sdl2-x86_64` (`$NATIVE_SDK`).
The release archive is SHA-256 pinned and includes `libnative.a`, public headers,
dependency libraries, `manifest.json`, licenses, and the `Native::Native` CMake target.
The image build compiles and links a consumer against this installed SDK.

Configure consumers with `-DNative_DIR="$NATIVE_SDK/lib/cmake/Native"`, then
use `find_package(Native CONFIG REQUIRED)` and link `Native::Native`.
