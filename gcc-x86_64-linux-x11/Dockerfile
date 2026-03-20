# GCC x86_64 Linux X11 development toolchain (Ubuntu 22.04)
FROM ubuntu:22.04

ARG IMG_VERSION=1.0.0

LABEL org.opencontainers.image.title="gcc-x86_64-linux-x11" \
      org.opencontainers.image.description="GCC x86_64 Linux X11 development base with Mesa/OpenGL plus image and font tooling." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive

# Core build, X11, OpenGL, image, and font tooling.
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    make \
    git \
    gdb \
    valgrind \
    file \
    # X11 development libraries
    libx11-dev \
    libxext-dev \
    libxrandr-dev \
    libxcursor-dev \
    libxi-dev \
    libxinerama-dev \
    libxxf86vm-dev \
    libxss-dev \
    libxrender-dev \
    libxft-dev \
    libxmu-dev \
    libxpm-dev \
    libxt-dev \
    # X11 runtime utilities
    x11-apps \
    x11-utils \
    x11-xserver-utils \
    xauth \
    # OpenGL (Mesa)
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libegl1-mesa-dev \
    mesa-utils \
    # Image format development libraries
    libpng-dev \
    libjpeg-dev \
    libtiff-dev \
    libwebp-dev \
    librsvg2-dev \
    # Image and vector tooling
    imagemagick \
    netpbm \
    librsvg2-bin \
    ghostscript \
    # Font / text rendering libraries
    libfreetype6-dev \
    libfontconfig1-dev \
    # Font inspection and conversion tooling
    fontconfig \
    fonttools \
    fonts-dejavu-core \
    fonts-dejavu-extra \
    fonts-freefont-ttf \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work

# Sanity checks
RUN echo "=== Compiler ===" && gcc --version && g++ --version \
 && echo "=== CMake ===" && cmake --version \
 && echo "=== pkg-config ===" && pkg-config --version \
 && echo "=== GDB ===" && gdb --version | head -1 \
 && echo "=== X11 ===" && pkg-config --modversion x11 \
 && echo "=== Xrender ===" && pkg-config --modversion xrender \
 && echo "=== Xft ===" && pkg-config --modversion xft \
 && echo "=== OpenGL ===" && pkg-config --modversion gl \
 && echo "=== Fontconfig ===" && pkg-config --modversion fontconfig \
 && echo "=== FreeType ===" && pkg-config --modversion freetype2 \
 && echo "--- Compile test ---" \
 && printf '#include <X11/Xlib.h>\nint main(void){Display *d=XOpenDisplay(0); if(d) XCloseDisplay(d); return 0;}\n' > /tmp/test.c \
 && gcc -o /tmp/test /tmp/test.c $(pkg-config --cflags --libs x11) \
 && rm -f /tmp/test /tmp/test.c \
 && echo "All checks passed."
