# GCC x86_64 Linux X11 development toolchain (Ubuntu 22.04)
FROM ubuntu:22.04

ARG IMG_VERSION=1.2.0
ARG LIBXAW_VERSION=1.0.16
ARG LIBXAW_REVISION=0877699c1fb9ef29a2a1e4429b5f77fd5c3adc5c

LABEL org.opencontainers.image.title="gcc-x86_64-linux-x11" \
      org.opencontainers.image.description="GCC x86_64 Linux X11 development base with original Athena widgets, Mesa/OpenGL, and image/font tooling." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}" \
      org.opencontainers.image.libxaw.version="${LIBXAW_VERSION}" \
      org.opencontainers.image.libxaw.revision="${LIBXAW_REVISION}"

ENV DEBIAN_FRONTEND=noninteractive

# Core build, X11, OpenGL, image, and font tooling.
RUN apt-get update && apt-get install -y \
    build-essential \
    autoconf \
    automake \
    libtool \
    cmake \
    pkg-config \
    make \
    git \
    python3 \
    gdb \
    valgrind \
    file \
    # X11 development libraries
    x11proto-dev \
    xutils-dev \
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
    # Headless and nested X servers for integration testing
    xvfb \
    xserver-xephyr \
    xfonts-utils \
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

COPY packages/libXaw-1.0.16.tar.xz packages/libXaw-1.0.16.tar.xz.sha256 /tmp/libxaw-source/

# Build the original X.Org Athena Widget Set from the supplied source. Both
# supported ABIs, shared/static libraries, headers, manuals, and pkg-config
# metadata are installed. Generic libXaw compatibility links select ABI 7.
RUN set -eux; \
    srcdir="$(mktemp -d)"; \
    cd /tmp/libxaw-source; \
    sha256sum --check libXaw-1.0.16.tar.xz.sha256; \
    tar -xJf libXaw-1.0.16.tar.xz -C "$srcdir"; \
    cd "$srcdir"; \
    autoreconf --force --install; \
    ./configure \
      --prefix=/usr/local \
      --enable-xaw6 \
      --enable-xaw7 \
      --disable-specs \
      --disable-unit-tests; \
    make --jobs="$(nproc)"; \
    make install; \
    ln -sfn libXaw7.so /usr/local/lib/libXaw.so; \
    ln -sfn libXaw7.a /usr/local/lib/libXaw.a; \
    ln -sfn xaw7.pc /usr/local/lib/pkgconfig/xaw.pc; \
    install -d /usr/local/share/doc/libXaw; \
    install -m 0644 COPYING README.md /usr/local/share/doc/libXaw/; \
    printf '%s\n' \
      "version=${LIBXAW_VERSION}" \
      "revision=${LIBXAW_REVISION}" \
      > /usr/local/share/doc/libXaw/SOURCE; \
    ldconfig; \
    cd /; \
    rm -rf "$srcdir" /tmp/libxaw-source

WORKDIR /work

# Sanity checks
RUN echo "=== Compiler ===" && gcc --version && g++ --version \
 && echo "=== CMake ===" && cmake --version \
 && echo "=== pkg-config ===" && pkg-config --version \
 && echo "=== GDB ===" && gdb --version | head -1 \
 && echo "=== X11 ===" && pkg-config --modversion x11 \
 && echo "=== X11 test servers ===" && command -v Xvfb && command -v Xephyr \
 && echo "=== X11 font tools ===" && command -v mkfontdir \
 && echo "=== Xrender ===" && pkg-config --modversion xrender \
 && echo "=== Xft ===" && pkg-config --modversion xft \
 && echo "=== Athena widgets ===" \
 && dpkg-query -W x11proto-dev libx11-dev libxext-dev libxt-dev libxmu-dev libxpm-dev \
 && pkg-config --exists xproto xextproto x11 xext xt xmu xpm \
 && test "$(pkg-config --modversion xaw6)" = "${LIBXAW_VERSION}" \
 && test "$(pkg-config --modversion xaw7)" = "${LIBXAW_VERSION}" \
 && test "$(pkg-config --modversion xaw)" = "${LIBXAW_VERSION}" \
 && test -f /usr/local/lib/libXaw6.a \
 && test -f /usr/local/lib/libXaw7.a \
 && test -L /usr/local/lib/libXaw.so \
 && test -L /usr/local/lib/libXaw.a \
 && test -f /usr/local/include/X11/Xaw/Form.h \
 && test -f /usr/local/include/X11/Xaw/FormP.h \
 && echo "=== OpenGL ===" && pkg-config --modversion gl \
 && echo "=== Fontconfig ===" && pkg-config --modversion fontconfig \
 && echo "=== FreeType ===" && pkg-config --modversion freetype2 \
 && echo "--- Compile test ---" \
 && printf '#include <X11/Xlib.h>\nint main(void){Display *d=XOpenDisplay(0); if(d) XCloseDisplay(d); return 0;}\n' > /tmp/test.c \
 && gcc -o /tmp/test /tmp/test.c $(pkg-config --cflags --libs x11) \
 && printf '#include <X11/Intrinsic.h>\n#include <X11/Xaw/Form.h>\nint main(void){WidgetClass c = formWidgetClass; return c == 0;}\n' > /tmp/test-xaw.c \
 && gcc -o /tmp/test-xaw /tmp/test-xaw.c $(pkg-config --cflags --libs xaw7) \
 && gcc -o /tmp/test-xaw-classic /tmp/test-xaw.c -L/usr/local/lib -lXaw -lXt -lX11 \
 && rm -f /tmp/test /tmp/test.c /tmp/test-xaw /tmp/test-xaw.c /tmp/test-xaw-classic \
 && echo "All checks passed."
