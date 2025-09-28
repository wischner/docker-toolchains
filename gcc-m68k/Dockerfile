# GCC m68k-elf bare-metal toolchain on Alpine (single-stage)
FROM alpine:3.20

ARG IMG_VERSION=1.0.0
ARG BINUTILS_VER=2.42
ARG GCC_VER=13.2.0

LABEL org.opencontainers.image.title="gcc-m68k" \
      org.opencontainers.image.description="GCC m68k-elf bare-metal toolchain (Binutils + GCC C + libgcc) on Alpine (single-stage)." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later and others; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV PREFIX=/opt/m68k-elf \
    TARGET=m68k-elf \
    PATH="/opt/m68k-elf/bin:${PATH}"

# Build + runtime tools and libs needed by GCC
RUN apk add --no-cache \
    bash ca-certificates wget curl tar xz bzip2 \
    build-base gmp-dev mpfr-dev mpc1-dev isl-dev zlib-dev \
    texinfo flex bison ncurses-dev

WORKDIR /tmp/build

# ---------------------
# Build Binutils (m68k)
# ---------------------
RUN set -e; \
    wget -q https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VER}.tar.xz; \
    tar -xf binutils-${BINUTILS_VER}.tar.xz; \
    mkdir -p binutils-build && cd binutils-build; \
    ../binutils-${BINUTILS_VER}/configure \
      --target=${TARGET} \
      --prefix=${PREFIX} \
      --disable-nls \
      --disable-werror; \
    make -j"$(getconf _NPROCESSORS_ONLN)"; \
    make install

# -----------------------------------------
# Build GCC (stage1 C only, bare-metal)
# - Uses system gmp/mpfr/mpc/isl
# - without headers (no newlib yet)
# - installs libgcc so bare-metal linking works
# -----------------------------------------
RUN set -e; \
    cd /tmp/build; \
    wget -q https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.xz; \
    tar -xf gcc-${GCC_VER}.tar.xz; \
    mkdir -p gcc-build && cd gcc-build; \
    ../gcc-${GCC_VER}/configure \
      --target=${TARGET} \
      --prefix=${PREFIX} \
      --disable-nls \
      --enable-languages=c \
      --without-headers \
      --disable-shared \
      --disable-threads \
      --disable-libssp \
      --with-system-zlib; \
    make -j"$(getconf _NPROCESSORS_ONLN)" all-gcc; \
    make install-gcc; \
    make -j"$(getconf _NPROCESSORS_ONLN)" all-target-libgcc; \
    make install-target-libgcc

# Tidy up to keep the image lean(ish)
RUN rm -rf /tmp/build && \
    find "${PREFIX}" -type f -name '*.la' -delete && \
    strip "${PREFIX}"/bin/* || true && \
    find "${PREFIX}"/libexec -type f -exec sh -c 'file -b "$1" | grep -q ELF && strip "$1" || true' _ {} \; || true

WORKDIR /work

# Sanity checks (aligns with your style)
RUN set -e; \
    echo "=== m68k-elf toolchain ==="; \
    m68k-elf-gcc --version | head -n1; \
    m68k-elf-ld --version  | head -n1; \
    echo "Prefix: ${PREFIX}"; \
    echo "Target: ${TARGET}"; \
    echo "Ready."
