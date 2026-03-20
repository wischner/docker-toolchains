# GCC x86_64 Linux SDL development toolchain (Ubuntu 22.04)
ARG BASE_IMAGE=wischner/gcc-x86_64-linux-x11:1.0.0
FROM ${BASE_IMAGE}

ARG IMG_VERSION=1.0.0
ARG SDL3_VERSION=3.2.0

LABEL org.opencontainers.image.title="gcc-x86_64-linux-sdl" \
      org.opencontainers.image.description="GCC x86_64 Linux SDL2 and SDL3 development toolchain layered on the Linux X11 base image." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive

# SDL2 packages from Ubuntu plus build prerequisites for SDL3 from source.
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    libsdl2-dev \
    libsdl2-image-dev \
    libsdl2-mixer-dev \
    libsdl2-ttf-dev \
    libvorbis-dev \
    libogg-dev \
    libflac-dev \
    libmpg123-dev \
    libopus-dev \
    libwayland-dev \
    libxkbcommon-dev \
    libpulse-dev \
    libasound2-dev \
    && rm -rf /var/lib/apt/lists/*

# SDL3 is built from the official source release because Ubuntu 22.04 does not
# consistently provide a native libsdl3-dev package.
RUN set -eux; \
    tmpdir="$(mktemp -d)"; \
    curl -fsSL -o "$tmpdir/sdl3.tar.gz" "https://github.com/libsdl-org/SDL/releases/download/release-${SDL3_VERSION}/SDL3-${SDL3_VERSION}.tar.gz"; \
    tar -xzf "$tmpdir/sdl3.tar.gz" -C "$tmpdir"; \
    cmake -S "$tmpdir/SDL3-${SDL3_VERSION}" -B "$tmpdir/build" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DSDL_SHARED=ON \
      -DSDL_STATIC=OFF \
      -DSDL_TESTS=OFF; \
    cmake --build "$tmpdir/build" -j"$(nproc)"; \
    cmake --install "$tmpdir/build"; \
    ldconfig; \
    rm -rf "$tmpdir"

WORKDIR /work

# Sanity checks
RUN echo "=== Compiler ===" && gcc --version && g++ --version \
 && echo "=== CMake ===" && cmake --version \
 && echo "=== pkg-config ===" && pkg-config --version \
 && echo "=== GDB ===" && gdb --version | head -1 \
 && echo "=== Base X11 ===" && pkg-config --modversion x11 \
 && echo "=== SDL2 ===" && pkg-config --modversion sdl2 \
 && echo "=== SDL2_image ===" && pkg-config --modversion SDL2_image \
 && echo "=== SDL2_mixer ===" && pkg-config --modversion SDL2_mixer \
 && echo "=== SDL2_ttf ===" && pkg-config --modversion SDL2_ttf \
 && echo "=== SDL3 ===" && pkg-config --modversion sdl3 \
 && echo "=== OpenGL ===" && pkg-config --modversion gl \
 && echo "--- Compile tests ---" \
 && printf '#include <SDL2/SDL.h>\nint main(){SDL_Init(0);SDL_Quit();return 0;}\n' > /tmp/test.c \
 && gcc -o /tmp/test /tmp/test.c $(pkg-config --cflags --libs sdl2) \
 && printf '#include <SDL3/SDL.h>\nint main(){SDL_Init(0);SDL_Quit();return 0;}\n' > /tmp/test3.c \
 && gcc -o /tmp/test3 /tmp/test3.c $(pkg-config --cflags --libs sdl3) \
 && rm -f /tmp/test /tmp/test.c /tmp/test3 /tmp/test3.c \
 && echo "All checks passed."
