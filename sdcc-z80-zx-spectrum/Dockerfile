# ZX Spectrum toolchain on Alpine:
# - Base: your sdcc-z80 (Alpine, single-stage, includes SDCC + uCsim)
# - Adds: python3, which
# - Builds: libspectrum + Fuse (SDL backend) from source
# - Keeps: bin2tap + wrappers from earlier example
ARG BASE_IMAGE=wischner/sdcc-z80:latest
FROM ${BASE_IMAGE}

ARG IMG_VERSION=1.0.0

LABEL org.opencontainers.image.title="sdcc-z80-zx-spectrum" \
      org.opencontainers.image.description="SDCC Z80 toolchain + ZX Spectrum helpers (bin2tap) + Fuse emulator (SDL) built on Alpine" \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

# Small runtime bits you asked for
RUN apk add --no-cache python3 which

# Build deps for libspectrum + fuse (SDL)
# autoconf/automake/libtool/pkgconf: autotools
# zlib-dev, libpng-dev, libxml2-dev, libarchive-dev: file formats
# glib-dev: common util dep
# sdl2-dev: we’ll build Fuse with SDL backend (avoid GTK on Alpine)
# git, ca-certs, build-base: usual suspects
# Build deps (no autotools needed with release tarballs)
RUN apk add --no-cache \
    git ca-certificates build-base pkgconf curl tar \
    zlib-dev libpng-dev libxml2-dev libarchive-dev \
    glib-dev sdl2-dev \
    autoconf automake libtool \
    readline-dev

# Build & install libspectrum (release tarball, direct mirror)
RUN set -eux; \
    ver=1.5.0; \
    url="https://downloads.sourceforge.net/project/fuse-emulator/libspectrum/${ver}/libspectrum-${ver}.tar.gz"; \
    curl -fL "$url" -o /tmp/libspectrum.tar.gz || \
      curl -fL "https://pilotfiber.dl.sourceforge.net/project/fuse-emulator/libspectrum/${ver}/libspectrum-${ver}.tar.gz" -o /tmp/libspectrum.tar.gz; \
    file /tmp/libspectrum.tar.gz | grep -qi 'gzip' || { echo "Not a gzip, got:"; head -50 /tmp/libspectrum.tar.gz; exit 1; } ; \
    tar -C /tmp -xzf /tmp/libspectrum.tar.gz; \
    cd /tmp/libspectrum-${ver}; \
    ./configure --prefix=/usr; \
    make -j"$(getconf _NPROCESSORS_ONLN)"; \
    make install; \
    rm -rf /tmp/libspectrum*


# Build & install Fuse (speccytools fork with GDB support, SDL backend)
# Build & install Fuse (speccytools fork with GDB support, SDL backend)
RUN set -eux; \
    git -c credential.helper= -c http.https://github.com/.extraHeader= \
        clone --depth=1 https://github.com/speccytools/fuse.git /tmp/fuse && \
    cd /tmp/fuse && \
    ./autogen.sh && \
    ./configure --prefix=/usr --with-sdl --without-gtk --disable-werror && \
    make -j"$(getconf _NPROCESSORS_ONLN)" && \
    make install && \
    fuse --help >/dev/null 2>&1 || true; \
    rm -rf /tmp/fuse


# ZX helpers: bin2tap + wrappers
# (If you already added these in a previous iteration, this is idempotent)
RUN set -e; \
    git clone --depth=1 https://github.com/compilersoftware/bin2tap.git /tmp/bin2tap && \
    make -C /tmp/bin2tap && \
    install -m 0755 /tmp/bin2tap/bin2tap /usr/local/bin/bin2tap && \
    rm -rf /tmp/bin2tap && \
    printf '#!/bin/sh\nexec sdcc -mz80 -DSPECTRUM "$@"\n' > /usr/local/bin/zx-sdcc && \
    chmod +x /usr/local/bin/zx-sdcc && \
    printf '%s\n' \
    '#!/bin/sh' \
    'set -e' \
    'in="$1"; [ -n "$in" ] || { echo "Usage: ihx2bin <file.ihx>"; exit 2; }' \
    'base="${in%.*}"' \
    'packihx "$in" > "$base.packed.ihx"' \
    'makebin -p "$base.packed.ihx" "$base.bin"' \
    'echo "Wrote $base.bin"' \
        > /usr/local/bin/ihx2bin && chmod +x /usr/local/bin/ihx2bin && \
        printf '%s\n' \
    '#!/bin/sh' \
    'set -e' \
    'in="$1"; addr="${2:-32768}"' \
    '[ -n "$in" ] || { echo "Usage: ihx2tap <file.ihx> [LOAD_ADDR]"; exit 2; }' \
    'base="${in%.*}"' \
    'packihx "$in" > "$base.packed.ihx"' \
    'makebin -p "$base.packed.ihx" "$base.bin"' \
    'bin2tap -a "$addr" "$base.bin" "$base.tap"' \
    'echo "Wrote $base.tap (load at $addr)"' \
    > /usr/local/bin/ihx2tap && chmod +x /usr/local/bin/ihx2tap

# ROMs handling
# We do NOT ship Spectrum ROMs (copyright). Mount them at runtime:
#   -v /path/to/roms:/opt/roms
# Fuse will look here by default. You can override via FUSE_ROM_DIR.
ENV FUSE_ROM_DIR=/opt/roms
RUN mkdir -p /opt/roms

# Convenience wrapper to run Fuse pointing at the ROM dir (if you want SDL window)
# Usage inside container (with X/Wayland mapped) or via host:
#   fuse-run <tape.tap>
RUN printf '%s\n' \
'#!/bin/sh' \
'ROMDIR="${FUSE_ROM_DIR:-/opt/roms}"' \
'exec fuse --roms "$ROMDIR" "$@"' \
> /usr/local/bin/fuse-run && chmod +x /usr/local/bin/fuse-run

WORKDIR /work

# Quick prints so logs show what’s in the image (non-fatal if headless)
RUN set -e; \
    echo "== ZX Spectrum Alpine toolchain =="; \
    sdcc --version; \
    which fuse || true; \
    fuse --help >/dev/null 2>&1 || true; \
    which bin2tap; \
    which zx-sdcc; \
    which ihx2bin; \
    which ihx2tap
