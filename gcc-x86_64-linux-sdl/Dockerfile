# GCC x86_64 Linux SDL development toolchain (Ubuntu 22.04)
ARG BASE_IMAGE=wischner/gcc-x86_64-linux-x11:1.6.0
FROM ${BASE_IMAGE}

ARG IMG_VERSION=1.4.0
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


# Pinned Native release SDK: public headers, libraries, CMake package and notices.
ARG NATIVE_VERSION=v1.1.0
ARG NATIVE_SHA256=abca049b8af97e3302ab1b6da6e149466fbbbe772728260a857d4eae6d000560
ENV NATIVE_SDK=/opt/native/linux-sdl2-x86_64
ADD --checksum=sha256:${NATIVE_SHA256} https://github.com/wischner/native/releases/download/${NATIVE_VERSION}/native-${NATIVE_VERSION}-linux-sdl2-x86_64-sdk.tar.gz /tmp/native-sdk.tar.gz
RUN set -eux; \
    install -d "${NATIVE_SDK}"; \
    tar -xzf /tmp/native-sdk.tar.gz -C "${NATIVE_SDK}" --strip-components=1; \
    rm /tmp/native-sdk.tar.gz; \
    test -s "${NATIVE_SDK}/include/native.h"; \
    test -s "${NATIVE_SDK}/lib/libnative.a"; \
    test -s "${NATIVE_SDK}/lib/cmake/Native/NativeConfig.cmake"; \
    test -s "${NATIVE_SDK}/manifest.json"; \
    printf '%s\n' "${NATIVE_VERSION}" > "${NATIVE_SDK}/.version"; \
    printf '%s\n' "${NATIVE_SHA256}" > "${NATIVE_SDK}/.sha256"

# Compile and link a consumer using only the installed SDK's public interface.
RUN set -eux; \
    install -d /tmp/native-consumer; \
    printf '%s\n' \
      '#include <native.h>' \
      'int program(int, char **) {' \
      '  native::app_wnd window("Native SDK check");' \
      '  return 0;' \
      '}' > /tmp/native-consumer/main.cpp; \
    printf '%s\n' \
      'cmake_minimum_required(VERSION 3.20)' \
      'project(native_consumer LANGUAGES CXX)' \
      'find_package(Native CONFIG REQUIRED)' \
      'add_executable(native_consumer main.cpp)' \
      'target_link_libraries(native_consumer PRIVATE Native::Native)' \
      > /tmp/native-consumer/CMakeLists.txt; \
    cmake -S /tmp/native-consumer -B /tmp/native-consumer/build \
      -DCMAKE_BUILD_TYPE=Release \
      -DNative_DIR="${NATIVE_SDK}/lib/cmake/Native"; \
    cmake --build /tmp/native-consumer/build; \
    ldd /tmp/native-consumer/build/native_consumer > /tmp/native-consumer/ldd.txt; \
    cat /tmp/native-consumer/ldd.txt; \
    ! grep -q "not found" /tmp/native-consumer/ldd.txt; \
    rm -rf /tmp/native-consumer

LABEL org.opencontainers.image.native.version="${NATIVE_VERSION}" \
      org.opencontainers.image.native.sdk="linux-sdl2-x86_64" \
      org.opencontainers.image.native.sha256="${NATIVE_SHA256}"
