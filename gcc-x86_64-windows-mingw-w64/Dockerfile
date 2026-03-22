# GCC x86_64 Windows MinGW-w64 cross-compilation toolchain (Ubuntu 22.04)
FROM ubuntu:22.04

ARG IMG_VERSION=1.0.0
ARG MINGW_TRIPLET=x86_64-w64-mingw32

LABEL org.opencontainers.image.title="gcc-x86_64-windows-mingw-w64" \
      org.opencontainers.image.description="GCC x86_64 MinGW-w64 cross-compilation toolchain for building Windows applications from Linux." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive

# Core build tools, MinGW-w64 cross toolchain, common cross-target libraries,
# and practical Windows packaging/signing/testing helpers.
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    make \
    git \
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
