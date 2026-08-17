# GCC m68k-elf bare-metal C/C++ toolchain on Alpine
FROM alpine:3.23 AS builder

ARG BINUTILS_VER=2.46.1
ARG BINUTILS_SHA512=a5c65e56e400ed3fb8906a995dbb93eb5bea54b16344244653d7f44ef29ceb60270da263b19d25302c37759784e14fcb4b9421b29e0e2c7f450bd99f6bb4595c
ARG GCC_VER=16.1.0
ARG GCC_SHA512=b3454958891ab47e1e5b6cb9396c0ad3b04f32fe2a7bf1153a143f21013fdb6b295ca94c98964698a688e4c1d7555ffd8ffbc20187507cce6b1c32cbcc09897a

ENV PREFIX=/opt/m68k-elf \
    TARGET=m68k-elf \
    PATH="/opt/m68k-elf/bin:${PATH}"

RUN apk add --no-cache \
    bash bison build-base bzip2 ca-certificates file flex gmp-dev isl-dev \
    mpc1-dev mpfr-dev ncurses-dev perl tar texinfo wget xz zlib-dev

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

WORKDIR /tmp/build

# Build the current GNU Binutils release for m68k-elf.
RUN wget -q "https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VER}.tar.xz" && \
    echo "${BINUTILS_SHA512}  binutils-${BINUTILS_VER}.tar.xz" | sha512sum -c - && \
    tar -xf "binutils-${BINUTILS_VER}.tar.xz" && \
    mkdir binutils-build && \
    cd binutils-build && \
    "../binutils-${BINUTILS_VER}/configure" \
      --target="${TARGET}" \
      --prefix="${PREFIX}" \
      --disable-nls \
      --disable-werror && \
    make -j"$(getconf _NPROCESSORS_ONLN)" && \
    make install

# Build both modern C and C++ front ends. This remains a deliberately
# freestanding toolchain: it supplies libgcc but no target libc/libstdc++.
RUN wget -q "https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.xz" && \
    echo "${GCC_SHA512}  gcc-${GCC_VER}.tar.xz" | sha512sum -c - && \
    tar -xf "gcc-${GCC_VER}.tar.xz" && \
    mkdir gcc-build && \
    cd gcc-build && \
    "../gcc-${GCC_VER}/configure" \
      --target="${TARGET}" \
      --prefix="${PREFIX}" \
      --disable-nls \
      --enable-languages=c,c++ \
      --without-headers \
      --disable-shared \
      --disable-threads \
      --disable-libssp \
      --disable-libstdcxx \
      --with-system-zlib && \
    make -j"$(getconf _NPROCESSORS_ONLN)" all-gcc && \
    make install-gcc && \
    make -j"$(getconf _NPROCESSORS_ONLN)" all-target-libgcc && \
    make install-target-libgcc

RUN rm -rf /tmp/build && \
    find "${PREFIX}" -type f -name '*.la' -delete && \
    find "${PREFIX}" -type f -exec sh -c \
      'file -b "$1" | grep -q ELF && strip "$1" 2>/dev/null || true' _ {} \;

FROM alpine:3.23

ARG IMG_VERSION=1.2.0

LABEL org.opencontainers.image.title="gcc-m68k" \
      org.opencontainers.image.description="Modern GCC m68k-elf bare-metal C/C++ toolchain with GNU Binutils and libgcc on Alpine." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later and others; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV PREFIX=/opt/m68k-elf \
    TARGET=m68k-elf \
    PATH="/opt/m68k-elf/bin:${PATH}"

RUN apk add --no-cache \
    bash ca-certificates cmake file git gmp isl26 make mpc1 mpfr4 ninja perl \
    pkgconf python3 zlib zstd-libs

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

COPY --from=builder /opt/m68k-elf /opt/m68k-elf

WORKDIR /work

# Confirm both front ends and the complete binary utility set. The C++23 test
# intentionally uses no headers because this image has no target C++ runtime.
RUN for tool in gcc g++ cpp as ld ar ranlib nm objcopy objdump readelf size strings strip; do \
      command -v "${TARGET}-${tool}" >/dev/null; \
    done && \
    "${TARGET}-gcc" --version | head -n1 && \
    "${TARGET}-g++" --version | head -n1 && \
    printf '%s\n' \
      'consteval int answer() { return 42; }' \
      'static_assert(answer() == 42);' \
      'extern "C" int value() { return answer(); }' >/tmp/modern.cpp && \
    "${TARGET}-g++" -std=c++23 -ffreestanding -fno-exceptions -fno-rtti \
      -c /tmp/modern.cpp -o /tmp/modern.o && \
    "${TARGET}-objdump" -f /tmp/modern.o | grep -q 'm68k' && \
    rm /tmp/modern.cpp /tmp/modern.o
