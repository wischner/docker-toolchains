# GCC x86_64 Linux SDL2 development toolchain (Ubuntu 22.04)
FROM ubuntu:22.04

ARG IMG_VERSION=1.0.0

LABEL org.opencontainers.image.title="gcc-x86_64-linux-sdl" \
      org.opencontainers.image.description="GCC x86_64 Linux SDL2 development toolchain with Mesa/OpenGL, X11, and debugging support." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive

# ── Core build tools ────────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    make \
    git \
    gdb \
    valgrind \
    # ── SDL2 libraries ──────────────────────────────────────────────
    libsdl2-dev \
    libsdl2-image-dev \
    libsdl2-mixer-dev \
    libsdl2-ttf-dev \
    # ── Image format libraries ──────────────────────────────────────
    libpng-dev \
    libjpeg-dev \
    libtiff-dev \
    libwebp-dev \
    # ── Audio codec libraries ───────────────────────────────────────
    libvorbis-dev \
    libogg-dev \
    libflac-dev \
    libmpg123-dev \
    libopus-dev \
    # ── Font / text rendering ───────────────────────────────────────
    libfreetype6-dev \
    libfontconfig1-dev \
    # ── OpenGL (Mesa) ───────────────────────────────────────────────
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libegl1-mesa-dev \
    # ── X11 support ─────────────────────────────────────────────────
    libx11-dev \
    libxext-dev \
    libxrandr-dev \
    libxcursor-dev \
    libxi-dev \
    libxinerama-dev \
    libxxf86vm-dev \
    libxss-dev \
    # ── Wayland support (optional, pulled by SDL2) ──────────────────
    libwayland-dev \
    libxkbcommon-dev \
    # ── PulseAudio / ALSA (audio backends for SDL2_mixer) ──────────
    libpulse-dev \
    libasound2-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work

# ── Sanity checks ──────────────────────────────────────────────────
RUN echo "=== Compiler ===" && gcc --version && g++ --version \
 && echo "=== CMake ===" && cmake --version \
 && echo "=== pkg-config ===" && pkg-config --version \
 && echo "=== GDB ===" && gdb --version | head -1 \
 && echo "=== SDL2 ===" && pkg-config --modversion sdl2 \
 && echo "=== SDL2_image ===" && pkg-config --modversion SDL2_image \
 && echo "=== SDL2_mixer ===" && pkg-config --modversion SDL2_mixer \
 && echo "=== SDL2_ttf ===" && pkg-config --modversion SDL2_ttf \
 && echo "=== OpenGL ===" && pkg-config --modversion gl \
 && echo "--- Compile test ---" \
 && printf '#include <SDL2/SDL.h>\nint main(){SDL_Init(0);SDL_Quit();return 0;}\n' > /tmp/test.c \
 && gcc -o /tmp/test /tmp/test.c $(pkg-config --cflags --libs sdl2) \
 && rm -f /tmp/test /tmp/test.c \
 && echo "All checks passed."
