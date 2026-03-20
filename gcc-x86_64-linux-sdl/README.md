# GCC x86_64 Linux SDL toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is

A ready-to-use **SDL2 and SDL3 development environment** for Linux x86_64 based on Ubuntu 22.04.
It is intended for building SDL games and multimedia applications with full OpenGL, audio, and font support.

This image extends `wischner/gcc-x86_64-linux-x11` and adds SDL-focused libraries on top of the X11/OpenGL base.

## Installed components

- Everything from `wischner/gcc-x86_64-linux-x11`
- **GCC / G++** (Ubuntu 22.04 default toolchain)
- **CMake**, **Make**, **pkg-config**
- **GDB** and **Valgrind** for debugging and profiling
- **Git** for version control
- [SDL2](https://www.libsdl.org/) with `SDL2_image`, `SDL2_mixer`, `SDL2_ttf`
- [SDL3](https://www.libsdl.org/) available through `pkg-config sdl3`
- **OpenGL** (Mesa), GLU, EGL
- **X11** libraries and tools inherited from the X11 base image
- **Wayland** and xkbcommon
- Image codecs: libpng, libjpeg, libtiff, libwebp
- Audio codecs: libvorbis, libogg, libflac, libmpg123, libopus
- Audio backends: PulseAudio, ALSA
- Font rendering: FreeType, Fontconfig

## Using this image as your compiler (no interactive shell)

You don't need to "enter" the container. Just run the tools **from the host** and bind-mount your project. All outputs go to your current directory because `/work` inside the container is bound to `$PWD` on the host.

### Quick examples

```bash
# Compile a single SDL2 program
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-sdl:latest \
  gcc -o game main.c $(pkg-config --cflags --libs sdl2 SDL2_image SDL2_mixer SDL2_ttf gl)

# Compile a single SDL3 program
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-sdl:latest \
  gcc -o game3 main.c $(pkg-config --cflags --libs sdl3)

# CMake-based project build
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-sdl:latest \
  bash -c "cmake -S . -B build && cmake --build build -j"
```

### Interactive development

```bash
# Open an interactive shell
docker run --rm -it \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-sdl:latest \
  bash
```

### Running SDL applications with display (X11)

```bash
# Pass the host X11 display to the container
docker run --rm -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-sdl:latest \
  ./build/game
```

## Support and contributions

For bug reports, feature requests, or questions, please use the issue tracker:
[https://github.com/wischner/docker-toolchains/issues](https://github.com/wischner/docker-toolchains/issues)

Contributions are welcome. If you'd like to improve this image, feel free to open a pull request.
