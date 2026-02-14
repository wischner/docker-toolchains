# GCC x86_64 Linux SDL2 toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is
A ready-to-use **SDL2 development environment** for Linux x86_64 based on Ubuntu 22.04.
Intended for building SDL2 games and multimedia applications with full OpenGL, audio, and font support.

## Installed components
- **GCC / G++** (Ubuntu 22.04 default toolchain)
- **CMake**, **Make**, **pkg-config**
- **GDB** and **Valgrind** for debugging and profiling
- **Git** for version control
- [SDL2](https://www.libsdl.org/) with `SDL2_image`, `SDL2_mixer`, `SDL2_ttf`
- **OpenGL** (Mesa), GLU, EGL
- **X11** libraries (Xrandr, Xcursor, Xi, Xinerama, Xxf86vm, Xss)
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

### Running SDL2 applications with display (X11)

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
