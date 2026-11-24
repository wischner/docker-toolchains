# GCC x86_64 Windows MinGW-w64 cross-compilation toolchain (Ubuntu 24.04)
FROM ubuntu:24.04

ARG IMG_VERSION=1.2.0
ARG MINGW_TRIPLET=x86_64-w64-mingw32

LABEL org.opencontainers.image.title="gcc-x86_64-windows-mingw-w64" \
      org.opencontainers.image.description="GCC x86_64 MinGW-w64 cross-compilation toolchain for building Windows applications from Linux." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive

# Native v1.1.0 is built with GCC 13; Ubuntu 24.04 supplies the matching
# MinGW C++ ABI needed to link its release SDK.
# Core build tools, MinGW-w64 cross toolchain, common cross-target libraries,
# and practical Windows packaging/signing/testing helpers.
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    make \
    git \
    python3 \
    gdb \
    file \
    ca-certificates \
    curl \
    zip \
    unzip \
    xz-utils \
    # MinGW-w64 cross compiler and binutils (x86_64 target)
    binutils-mingw-w64-x86-64 \
    gcc-mingw-w64-x86-64-posix \
    g++-mingw-w64-x86-64-posix \
    mingw-w64-x86-64-dev \
    mingw-w64-tools \
    gdb-mingw-w64 \
    # Cross-target libraries available in Ubuntu repositories
    libz-mingw-w64-dev \
    win-iconv-mingw-w64-dev \
    libgpg-error-mingw-w64-dev \
    libgcrypt-mingw-w64-dev \
    libassuan-mingw-w64-dev \
    libksba-mingw-w64-dev \
    libnpth-mingw-w64-dev \
    # Packaging / release helpers
    nsis \
    osslsigncode \
    wine64 \
    && rm -rf /var/lib/apt/lists/*

# Ensure canonical compiler command names exist for docs/scripts and prefer
# the POSIX threading variant when alternatives are present.
RUN if update-alternatives --query "${MINGW_TRIPLET}-gcc" >/dev/null 2>&1; then \
      update-alternatives --set "${MINGW_TRIPLET}-gcc" "/usr/bin/${MINGW_TRIPLET}-gcc-posix"; \
    fi \
 && if update-alternatives --query "${MINGW_TRIPLET}-g++" >/dev/null 2>&1; then \
      update-alternatives --set "${MINGW_TRIPLET}-g++" "/usr/bin/${MINGW_TRIPLET}-g++-posix"; \
    fi \
 && [ -x "/usr/bin/${MINGW_TRIPLET}-gcc" ] || ln -s "/usr/bin/${MINGW_TRIPLET}-gcc-posix" "/usr/local/bin/${MINGW_TRIPLET}-gcc" \
 && [ -x "/usr/bin/${MINGW_TRIPLET}-g++" ] || ln -s "/usr/bin/${MINGW_TRIPLET}-g++-posix" "/usr/local/bin/${MINGW_TRIPLET}-g++"

# CMake toolchain file for convenient cross-build configuration.
RUN mkdir -p /opt/toolchains \
 && printf '%s\n' \
    'set(CMAKE_SYSTEM_NAME Windows)' \
    'set(CMAKE_SYSTEM_PROCESSOR x86_64)' \
    "set(CMAKE_C_COMPILER ${MINGW_TRIPLET}-gcc)" \
    "set(CMAKE_CXX_COMPILER ${MINGW_TRIPLET}-g++)" \
    "set(CMAKE_RC_COMPILER ${MINGW_TRIPLET}-windres)" \
    'set(CMAKE_FIND_ROOT_PATH /usr/x86_64-w64-mingw32)' \
    'set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)' \
    'set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)' \
    'set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)' \
    'set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)' \
    > /opt/toolchains/mingw-w64-x86_64.cmake

# Ubuntu 24.04 keeps the 64-bit Wine loader outside PATH.
RUN test -x /usr/lib/wine/wine64 \
 && ln -s /usr/lib/wine/wine64 /usr/local/bin/wine64

WORKDIR /work

# Sanity checks
RUN echo "=== Compiler ===" && gcc --version | head -1 \
 && echo "=== MinGW GCC ===" && ${MINGW_TRIPLET}-gcc --version | head -1 \
 && echo "=== MinGW G++ ===" && ${MINGW_TRIPLET}-g++ --version | head -1 \
 && echo "=== Binutils ===" && ${MINGW_TRIPLET}-ld --version | head -1 \
 && echo "=== Windres ===" && ${MINGW_TRIPLET}-windres --version | head -1 \
 && echo "=== MinGW GDB ===" && ${MINGW_TRIPLET}-gdb --version | head -1 \
 && echo "=== Wine ===" && wine64 --version \
 && echo "--- Compile tests ---" \
 && printf '#include <windows.h>\nint WINAPI WinMain(HINSTANCE h,HINSTANCE p,LPSTR c,int n){MessageBeep(MB_OK);return 0;}\n' > /tmp/winmain.c \
 && ${MINGW_TRIPLET}-gcc -O2 -s -o /tmp/winmain.exe /tmp/winmain.c \
 && printf '#include <winsock2.h>\nint main(void){WSADATA d; return WSAStartup(MAKEWORD(2,2), &d);}\n' > /tmp/winsock.c \
 && ${MINGW_TRIPLET}-gcc -O2 -s -o /tmp/winsock.exe /tmp/winsock.c -lws2_32 \
 && printf '#include <zlib.h>\nint main(void){return zlibVersion()[0]==0;}\n' > /tmp/ztest.c \
 && ${MINGW_TRIPLET}-gcc -O2 -s -o /tmp/ztest.exe /tmp/ztest.c -lz \
 && file /tmp/winmain.exe /tmp/winsock.exe /tmp/ztest.exe \
 && rm -f /tmp/winmain.c /tmp/winmain.exe /tmp/winsock.c /tmp/winsock.exe /tmp/ztest.c /tmp/ztest.exe \
 && echo "Toolchain checks passed."


# Pinned Native release SDK: public headers, libraries, CMake package and notices.
ARG NATIVE_VERSION=v1.1.0
ARG NATIVE_SHA256=82b14a34e3691041bf21245ac67c161d83a4d9964533ae9f1fe54e0d44af4e25
ENV NATIVE_SDK=/opt/native/windows-mingw-x86_64
ADD --checksum=sha256:${NATIVE_SHA256} https://github.com/wischner/native/releases/download/${NATIVE_VERSION}/native-${NATIVE_VERSION}-windows-mingw-x86_64-sdk.tar.gz /tmp/native-sdk.tar.gz
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
      -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/opt/toolchains/mingw-w64-x86_64.cmake \
      -DNative_DIR="${NATIVE_SDK}/lib/cmake/Native"; \
    cmake --build /tmp/native-consumer/build; \
    file /tmp/native-consumer/build/native_consumer.exe; \
    rm -rf /tmp/native-consumer

LABEL org.opencontainers.image.native.version="${NATIVE_VERSION}" \
      org.opencontainers.image.native.sdk="windows-mingw-x86_64" \
      org.opencontainers.image.native.sha256="${NATIVE_SHA256}"
