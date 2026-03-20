# GCC x86_64 Linux SDL Toolchain

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
  gcc -o game main.c $(pkg-config --cflags --libs sdl2 SDL2_image SDL2_mixer SDL2_ttf gl)
```

Compile an SDL3 application:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-sdl:latest \
  gcc -o game3 main.c $(pkg-config --cflags --libs sdl3)
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

## Support

Issues and pull requests are welcome:
<https://github.com/wischner/docker-toolchains>
