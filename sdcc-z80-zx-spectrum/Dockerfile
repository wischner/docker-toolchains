# ZX Spectrum toolchain on Alpine:
# - Base: your sdcc-z80 (Alpine, single-stage, includes SDCC + uCsim)
# - Adds: python3, which
# - Builds: libspectrum + Fuse (SDL backend) from source
# - Keeps: bin2tap + wrappers from earlier example
# - Adds: hdfmonkey plus blank FAT16 HDF images for divIDE/DivMMC/esxDOS
ARG BASE_IMAGE=wischner/sdcc-z80:latest
FROM ${BASE_IMAGE}

ARG IMG_VERSION=1.3.0
ARG HDFMONKEY_REF=master

LABEL org.opencontainers.image.title="sdcc-z80-zx-spectrum" \
      org.opencontainers.image.description="SDCC Z80 toolchain + ZX Spectrum helpers built on Alpine" \
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
# git, ca-certs, build-base: usual suspects
# Build deps (no autotools needed with release tarballs)
RUN apk add --no-cache \
    git ca-certificates build-base pkgconf \
    curl file tar \
    zlib-dev libpng-dev libxml2-dev libarchive-dev \
    glib-dev gtk+3.0 gtk+3.0-dev gdk-pixbuf-dev pango-dev cairo-dev \
    autoconf automake libtool \
    mbedtls-dev

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


# Build & install Fuse (speccytools fork with GDB support, GTK3 backend)
# Pinned to 70947ae (Dec 2024) — later Spectranext commits break disk.c
RUN set -eux; \
    git -c credential.helper= -c http.https://github.com/.extraHeader= \
        clone https://github.com/speccytools/fuse.git /tmp/fuse; \
    cd /tmp/fuse; \
    git checkout 70947ae; \
    ./autogen.sh; \
    # Prefer GTK3, fall back to generic GTK if needed; explicitly disable SDL
    ( ./configure --prefix=/usr --with-gtk3  --without-sdl --disable-werror \
      || ./configure --prefix=/usr --with-gtk  --without-sdl --disable-werror ); \
    make -j"$(getconf _NPROCESSORS_ONLN)"; \
    make install; \
    fuse --help >/dev/null 2>&1 || true; \
    rm -rf /tmp/fuse


# ZX helpers: bin2tap + conversion wrappers
RUN set -e; \
    git clone --depth=1 https://github.com/compilersoftware/bin2tap.git /tmp/bin2tap && \
    make -C /tmp/bin2tap && \
    install -m 0755 /tmp/bin2tap/bin2tap /usr/local/bin/bin2tap && \
    rm -rf /tmp/bin2tap && \
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

# hdfmonkey: create, format, and edit the FAT filesystems inside HDF (and raw
# IDE) disk images used by divIDE, DivMMC, +3e, and Fuse. Plain autotools, no
# external dependencies. Blank FAT16 volumes are generated for esxDOS and kept
# gzip-compressed because they are almost entirely zeros.
RUN set -eux; \
    git clone --depth=1 --branch "${HDFMONKEY_REF}" \
      https://github.com/gasman/hdfmonkey.git /tmp/hdfmonkey; \
    cd /tmp/hdfmonkey; \
    autoreconf -fi; \
    ./configure --prefix=/opt/hdfmonkey; \
    make -j"$(getconf _NPROCESSORS_ONLN)"; \
    mkdir -p \
      /opt/hdfmonkey/bin \
      /opt/hdfmonkey/share/hdfmonkey/images \
      /opt/hdfmonkey/share/licenses/hdfmonkey \
      /opt/hdfmonkey/share/doc/hdfmonkey; \
    install -m 0755 /tmp/hdfmonkey/src/hdfmonkey /opt/hdfmonkey/bin/hdfmonkey; \
    install -m 0644 /tmp/hdfmonkey/COPYING /opt/hdfmonkey/share/licenses/hdfmonkey/COPYING; \
    install -m 0644 /tmp/hdfmonkey/README /opt/hdfmonkey/share/doc/hdfmonkey/README; \
    install -m 0644 /tmp/hdfmonkey/CHANGELOG /opt/hdfmonkey/share/doc/hdfmonkey/CHANGELOG; \
    git -C /tmp/hdfmonkey rev-parse HEAD > /opt/hdfmonkey/.version; \
    printf '%s\n' 'https://github.com/gasman/hdfmonkey' > /opt/hdfmonkey/.source; \
    ln -s /opt/hdfmonkey/bin/hdfmonkey /usr/local/bin/hdfmonkey; \
    for size in 16M 32M 64M 128M; do \
      image="/opt/hdfmonkey/share/hdfmonkey/images/blank-$(printf '%s' "${size}" | tr 'M' 'm').hdf"; \
      hdfmonkey create --fat16 "${image}" "${size}" ESXDOS; \
      hdfmonkey ls "${image}" >/dev/null; \
      gzip -9 -n "${image}"; \
      test -s "${image}.gz"; \
    done; \
    cd /; \
    rm -rf /tmp/hdfmonkey

ENV HDFMONKEY_ROOT=/opt/hdfmonkey \
    HDFMONKEY_IMAGE_DIR=/opt/hdfmonkey/share/hdfmonkey/images

# Copy Sinclair roms.
RUN mkdir -p /usr/share/spectrum-roms/
COPY roms/ /usr/share/spectrum-roms/
ENV FUSE_ROM_DIR=/usr/share/spectrum-roms

# Set work dir.
WORKDIR /work

# Quick prints so logs show what’s in the image (non-fatal if headless)
RUN set -e; \
    echo "== ZX Spectrum Alpine toolchain =="; \
    sdcc --version; \
    which fuse || true; \
    fuse --help >/dev/null 2>&1 || true; \
    which bin2tap; \
    which ihx2bin; \
    which ihx2tap; \
    which hdfmonkey; \
    hdfmonkey help >/dev/null; \
    test -f "${HDFMONKEY_IMAGE_DIR}/blank-16m.hdf.gz"; \
    test -f "${HDFMONKEY_IMAGE_DIR}/blank-32m.hdf.gz"; \
    test -f "${HDFMONKEY_IMAGE_DIR}/blank-64m.hdf.gz"; \
    test -f "${HDFMONKEY_IMAGE_DIR}/blank-128m.hdf.gz"; \
    gunzip -c "${HDFMONKEY_IMAGE_DIR}/blank-16m.hdf.gz" > /tmp/smoke.hdf; \
    printf 'smoke\n' > /tmp/smoke.txt; \
    hdfmonkey mkdir /tmp/smoke.hdf /BIN; \
    hdfmonkey put /tmp/smoke.hdf /tmp/smoke.txt /BIN/SMOKE.TXT; \
    hdfmonkey ls /tmp/smoke.hdf /BIN | grep -F SMOKE.TXT; \
    hdfmonkey get /tmp/smoke.hdf /BIN/SMOKE.TXT /tmp/smoke-roundtrip.txt; \
    cmp /tmp/smoke.txt /tmp/smoke-roundtrip.txt; \
    rm -f /tmp/smoke.hdf /tmp/smoke.txt /tmp/smoke-roundtrip.txt
