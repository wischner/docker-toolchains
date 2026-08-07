# syntax=docker/dockerfile:1

# XCC Z80 toolchain for the Iskra Delta Partner
ARG BASE_IMAGE=wischner/xcc-z80:2.0.2

# Build Partner target libraries with XCC so the installed archives are
# self-contained and use the same object/archive formats as the base image.
FROM ${BASE_IMAGE} AS library-builder

ARG LIBGPX_VERSION=v0.2.0
ARG IDP_UDEV_REF=main

USER root

# Follow idp-udev and idp-sdk's current main branches. Keeping their Git
# directories lets the build record the exact revisions included in the image.
ADD --keep-git-dir=true https://github.com/iskra-delta/idp-udev.git#${IDP_UDEV_REF} /tmp/idp-udev
ADD --keep-git-dir=true https://github.com/iskra-delta/idp-sdk.git#main /tmp/idp-sdk

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends git make; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p /opt/idp/include /opt/idp/lib /opt/idp/share/licenses /opt/idp/share/metadata; \
    tmp_dir="$(mktemp -d)"; \
    curl -fsSL -o "${tmp_dir}/libgpx.tar.gz" \
      "https://github.com/retro-vault/libgpx/archive/refs/tags/${LIBGPX_VERSION}.tar.gz"; \
    mkdir -p "${tmp_dir}/libgpx" "${tmp_dir}/libgpx-obj"; \
    tar -xzf "${tmp_dir}/libgpx.tar.gz" -C "${tmp_dir}/libgpx" --strip-components=1; \
    for src in "${tmp_dir}"/libgpx/src/partner/*.s; do \
      name="$(basename "${src}" .s)"; \
      xas -g -o "${tmp_dir}/libgpx-obj/${name}.rel" "${src}"; \
    done; \
    xar --mode=gnu rcs /opt/idp/lib/libgpx.a "${tmp_dir}"/libgpx-obj/*.rel; \
    ln -s libgpx.a /opt/idp/lib/libgpx.lib; \
    install -m 0644 "${tmp_dir}/libgpx/include/libgpx.h" /opt/idp/include/libgpx.h; \
    mkdir -p /opt/idp/share/licenses/libgpx; \
    install -m 0644 "${tmp_dir}/libgpx/LICENSE" /opt/idp/share/licenses/libgpx/LICENSE; \
    printf '%s\n' "${LIBGPX_VERSION}" > /opt/idp/share/metadata/libgpx.version; \
    mkdir -p "${tmp_dir}/idp-udev-obj"; \
    for src in /tmp/idp-udev/src/ugpx/*.c; do \
      name="$(basename "${src}" .c)"; \
      xcc -std=c11 -Os \
        -I/tmp/idp-udev/include/gpx \
        -c "${src}" -o "${tmp_dir}/idp-udev-obj/${name}.rel"; \
    done; \
    for src in /tmp/idp-udev/src/ugpx/*.s; do \
      name="$(basename "${src}" .s)"; \
      xas -g -I /tmp/idp-udev/src/ugpx \
        -o "${tmp_dir}/idp-udev-obj/${name}.rel" "${src}"; \
    done; \
    xar --mode=gnu rcs /opt/idp/lib/libugpx.a "${tmp_dir}"/idp-udev-obj/*.rel; \
    ln -s libugpx.a /opt/idp/lib/libugpx.lib; \
    install -m 0644 /tmp/idp-udev/include/gpx/ugpx.h /opt/idp/include/ugpx.h; \
    mkdir -p /opt/idp/share/licenses/idp-udev; \
    install -m 0644 /tmp/idp-udev/LICENSE /opt/idp/share/licenses/idp-udev/LICENSE; \
    git -C /tmp/idp-udev rev-parse HEAD > /opt/idp/share/metadata/idp-udev.version; \
    test ! -e /opt/idp/lib/libulibc.a; \
    test ! -e /opt/idp/lib/ulibc.lib; \
    test ! -e /opt/idp/lib/libusdcc.a; \
    test ! -e /opt/idp/lib/usdcc.lib; \
    test ! -e /opt/idp/include/stdlib.h; \
    mkdir -p "${tmp_dir}/idp-sdk-build" "${tmp_dir}/idp-sdk-bin"; \
    make -C /tmp/idp-sdk/lib \
      TOOLCHAIN=xcc \
      DOCKER=off \
      ROOT=/tmp/idp-sdk \
      BUILD_DIR="${tmp_dir}/idp-sdk-build" \
      BIN_DIR="${tmp_dir}/idp-sdk-bin" \
      INCLUDE_DIR=/tmp/idp-sdk/include \
      "${tmp_dir}/idp-sdk-bin/libsdk.lib"; \
    cp -a /tmp/idp-sdk/include/. /opt/idp/include/; \
    install -m 0644 "${tmp_dir}/idp-sdk-bin/libsdk.lib" /opt/idp/lib/libsdk.a; \
    ln -s libsdk.a /opt/idp/lib/libsdk.lib; \
    mkdir -p /opt/idp/share/licenses/idp-sdk; \
    install -m 0644 /tmp/idp-sdk/LICENSE /opt/idp/share/licenses/idp-sdk/LICENSE; \
    git -C /tmp/idp-sdk rev-parse HEAD > /opt/idp/share/metadata/idp-sdk.version; \
    test ! -e /opt/idp/lib/libcpm3-z80.lib; \
    test ! -e /opt/idp/lib/libsdcc-z80.lib; \
    rm -rf "${tmp_dir}" /tmp/idp-udev /tmp/idp-sdk

# XEMU 2.0.2 can model Partner's RAM windows, but upstream port rules derive
# selectors from the transferred byte. Partner selects its banks by the I/O
# port address and ignores that byte, so add fixed selector values for IN/OUT.
FROM ${BASE_IMAGE} AS emulator-builder

ARG XYZ_VERSION=2.0.2

USER root

COPY xemu-partner.patch /tmp/xemu-partner.patch

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends binutils g++ make patch; \
    rm -rf /var/lib/apt/lists/*; \
    tmp_dir="$(mktemp -d)"; \
    xyz_tag="v${XYZ_VERSION#v}"; \
    curl -fsSL -o "${tmp_dir}/xyz.tar.gz" \
      "https://github.com/retro-vault/xyz/archive/refs/tags/${xyz_tag}.tar.gz"; \
    mkdir -p "${tmp_dir}/xyz" "${tmp_dir}/build" "${tmp_dir}/dist"; \
    tar -xzf "${tmp_dir}/xyz.tar.gz" -C "${tmp_dir}/xyz" --strip-components=1; \
    patch -d "${tmp_dir}/xyz" -p1 < /tmp/xemu-partner.patch; \
    make -C "${tmp_dir}/xyz/x/src/xemu" \
      ROOT="${tmp_dir}/xyz/x" \
      BUILD_DIR="${tmp_dir}/build" \
      DIST_DIR="${tmp_dir}/dist" \
      HOST_BIN_DIR="${tmp_dir}/dist/bin" \
      PUBLIC_LIB_DIR="${tmp_dir}/dist/lib" \
      XTOOLS_VERSION="${XYZ_VERSION#v}"; \
    install -m 0755 "${tmp_dir}/dist/bin/xemu" /opt/xemu-partner; \
    /opt/xemu-partner --version; \
    rm -rf "${tmp_dir}"

FROM ${BASE_IMAGE}

ARG IMG_VERSION=2.0.2
ARG XYZ_VERSION=2.0.2
ARG LIBGPX_VERSION=v0.2.0
ARG SNATCH_VERSION=v1.0.0
ARG CPMDISK_VERSION=v1.1.0

LABEL org.opencontainers.image.title="xcc-z80-idp" \
      org.opencontainers.image.description="XCC Z80 CP/M 3 toolchain for Iskra Delta Partner with the Partner SDK, libgpx, ugpx, snatch, and cpmdisk." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV IDP_ROOT=/opt/idp \
    IDP_INCLUDE_DIR=/opt/idp/include \
    IDP_LIB_DIR=/opt/idp/lib \
    SNATCH_PLUGIN_DIR=/opt/snatch/plugins \
    PATH="/usr/local/bin:/opt/x/bin:${PATH}"

USER root

COPY --from=library-builder /opt/idp/ /opt/idp/
COPY --from=emulator-builder /opt/xemu-partner /opt/x/bin/xemu
COPY --chmod=0755 xcc-cpm3 /usr/local/bin/xcc
COPY --chmod=0755 xld-cpm3 /usr/local/bin/xld
COPY libraries.manifest /opt/idp/libraries.manifest
COPY xemu-partner.conf /etc/xemu/partner.conf

# Install the published host tools and their required runtime payloads.
# The upstream release assets currently target Linux x86_64.
RUN set -eux; \
    test "${IMG_VERSION}" = "${XYZ_VERSION}"; \
    test "$(sed 's/^v//' /opt/x/.version)" = "${XYZ_VERSION#v}"; \
    test "$(uname -m)" = "x86_64"; \
    apt-get update; \
    apt-get install -y --no-install-recommends cmake git make; \
    rm -rf /var/lib/apt/lists/*; \
    tmp_dir="$(mktemp -d)"; \
    snatch_release="${SNATCH_VERSION#v}"; \
    snatch_asset="snatch-linux-x86_64-${snatch_release}.tar.gz"; \
    curl -fsSL -o "${tmp_dir}/snatch.tar.gz" \
      "https://github.com/retro-vault/snatch/releases/download/${SNATCH_VERSION}/${snatch_asset}"; \
    tar -xzf "${tmp_dir}/snatch.tar.gz" -C "${tmp_dir}"; \
    snatch_src="$(find "${tmp_dir}" -mindepth 1 -maxdepth 1 -type d -name 'snatch-*-linux-x86_64' | head -n1)"; \
    test -x "${snatch_src}/snatch"; \
    test -d "${snatch_src}/plugins"; \
    mkdir -p /opt/snatch; \
    install -m 0755 "${snatch_src}/snatch" /opt/snatch/snatch; \
    cp -a "${snatch_src}/plugins" /opt/snatch/plugins; \
    ln -s /opt/snatch/snatch /usr/bin/snatch; \
    printf '%s\n' "${SNATCH_VERSION}" > /opt/idp/share/metadata/snatch.version; \
    cpmdisk_release="${CPMDISK_VERSION#v}"; \
    cpmdisk_asset="cpmdisk-linux-x86_64-${cpmdisk_release}.tar.gz"; \
    curl -fsSL -o "${tmp_dir}/cpmdisk.tar.gz" \
      "https://github.com/iskra-delta/cpmdisk/releases/download/${CPMDISK_VERSION}/${cpmdisk_asset}"; \
    tar -xzf "${tmp_dir}/cpmdisk.tar.gz" -C "${tmp_dir}"; \
    cpmdisk_src="$(find "${tmp_dir}" -mindepth 1 -maxdepth 1 -type d -name 'cpmdisk-*-linux-x86_64' | head -n1)"; \
    test -x "${cpmdisk_src}/cpmdisk"; \
    test -f "${cpmdisk_src}/libcpmdisk.so"; \
    mkdir -p /opt/cpmdisk; \
    install -m 0755 "${cpmdisk_src}/cpmdisk" /opt/cpmdisk/cpmdisk; \
    install -m 0755 "${cpmdisk_src}/libcpmdisk.so" /opt/cpmdisk/libcpmdisk.so; \
    ln -s /opt/cpmdisk/cpmdisk /usr/bin/cpmdisk; \
    ln -s /opt/cpmdisk/libcpmdisk.so /usr/lib/libcpmdisk.so; \
    ldconfig; \
    printf '%s\n' "${CPMDISK_VERSION}" > /opt/idp/share/metadata/cpmdisk.version; \
    ln -s /opt/idp/include/libgpx.h /opt/x/z80/include/libgpx.h; \
    ln -s /opt/idp/include/ugpx.h /opt/x/z80/include/ugpx.h; \
    ln -s /opt/idp/include/partner /opt/x/z80/include/partner; \
    ln -s /opt/idp/lib/libgpx.a /opt/x/z80/lib/libgpx.a; \
    ln -s /opt/idp/lib/libugpx.a /opt/x/z80/lib/libugpx.a; \
    ln -s /opt/idp/lib/libsdk.a /opt/x/z80/lib/libsdk.a; \
    rm -f \
      /opt/x/z80/lib/crt0.rel \
      /opt/x/z80/lib/crt0.s \
      /opt/x/z80/lib/crt0-none.rel \
      /opt/x/z80/lib/crt0-none.s \
      /opt/x/z80/lib/libnone.a \
      /opt/x/z80/lib/linker.ld \
      /opt/x/z80/lib/linker.lk \
      /opt/x/z80/lib/linker-none.ld \
      /opt/x/z80/lib/linker-none.lk; \
    rm -rf /opt/x/include; \
    printf '%s\n' 'export PATH=/usr/local/bin:/opt/x/bin:$PATH' > /etc/profile.d/x.sh; \
    mkdir -p /home/ubuntu/.config/x; \
    ln -s /etc/xemu/partner.conf /home/ubuntu/.config/x/xemu.conf; \
    chown -R ubuntu:ubuntu /home/ubuntu/.config; \
    chown -R ubuntu:ubuntu /opt/idp; \
    rm -rf "${tmp_dir}"

USER ubuntu
WORKDIR /work

# Validate host tools, packaged public interfaces, excluded payloads, default
# CP/M 3 linkage, and independent full/micro Partner graphics programs.
RUN set -eux; \
    test "$(command -v xcc)" = /usr/local/bin/xcc; \
    test "$(command -v xld)" = /usr/local/bin/xld; \
    test "$(sh -lc 'command -v xcc')" = /usr/local/bin/xcc; \
    test "$(sh -lc 'command -v xld')" = /usr/local/bin/xld; \
    test "$(command -v snatch)" = /usr/bin/snatch; \
    test "$(command -v cpmdisk)" = /usr/bin/cpmdisk; \
    command -v make; \
    command -v cmake; \
    command -v git; \
    make --version >/dev/null; \
    cmake --version >/dev/null; \
    git --version >/dev/null; \
    snatch --help >/dev/null; \
    cpmdisk --help >/dev/null; \
    test ! -e /opt/snatch/include; \
    test ! -e /opt/cpmdisk/include; \
    test ! -e /usr/include/cpmdisk; \
    test ! -e /opt/x/include; \
    test -d /opt/x/z80/include; \
    test -f /opt/x/z80/lib/crt0-cpm3.rel; \
    test -f /opt/x/z80/lib/crt0-emu.rel; \
    test -f /opt/x/z80/lib/libcpm3.a; \
    test -f /opt/x/z80/lib/libemu.a; \
    test ! -e /opt/x/z80/lib/crt0.rel; \
    test ! -e /opt/x/z80/lib/crt0-none.rel; \
    test ! -e /opt/x/z80/lib/libnone.a; \
    test ! -e /opt/x/z80/lib/linker.ld; \
    test ! -e /opt/x/z80/lib/linker-none.ld; \
    test -f /opt/x/z80/include/libgpx.h; \
    test -f /opt/x/z80/include/ugpx.h; \
    test -f /opt/x/z80/include/partner/conio.h; \
    test ! -e /opt/idp/include/hw; \
    test ! -e /opt/x/z80/include/hw; \
    test -f /opt/x/z80/lib/libgpx.a; \
    test -f /opt/x/z80/lib/libugpx.a; \
    test -f /opt/x/z80/lib/libsdk.a; \
    test ! -e /opt/idp/lib/libulibc.a; \
    test ! -e /opt/idp/lib/libulibc.lib; \
    test ! -e /opt/idp/lib/ulibc.a; \
    test ! -e /opt/idp/lib/ulibc.lib; \
    test ! -e /opt/idp/lib/libusdcc.a; \
    test ! -e /opt/idp/lib/libusdcc.lib; \
    test ! -e /opt/idp/lib/usdcc.a; \
    test ! -e /opt/idp/lib/usdcc.lib; \
    for forbidden_header in \
      ctype.h io.h limits.h stdarg.h stdbool.h stddef.h \
      stdint.h stdio.h stdlib.h string.h; do \
      test ! -e "/opt/idp/include/${forbidden_header}"; \
    done; \
    test ! -e /opt/x/z80/lib/libulibc.a; \
    test ! -e /opt/x/z80/lib/libusdcc.a; \
    test ! -e /opt/idp/lib/sdkinit.rel; \
    test ! -e /opt/x/z80/lib/sdkinit.rel; \
    test ! -e /opt/idp/lib/libcpm3-z80.lib; \
    test ! -e /opt/idp/lib/libsdcc-z80.lib; \
    printf '%s\n' \
      '#include <libgpx.h>' \
      '#include <partner/conio.h>' \
      'int main(void) {' \
      '    gpx_t *gpx = gpx_create(GPXM_DEFAULT);' \
      '    cputs("XCC IDP");' \
      '    return gpx == 0;' \
      '}' \
      > /tmp/idp-smoke.c; \
    xcc /tmp/idp-smoke.c -lsdk -lgpx -o /tmp/idp-smoke.com; \
    test -s /tmp/idp-smoke.com; \
    printf '%s\n' \
      '#include <ugpx.h>' \
      'static unsigned char glyph[] = { 0 };' \
      'int main(void) {' \
      '    rect_t box = { 0, 0, 15, 15 };' \
      '    ginit(RES_1024x256);' \
      '    gsetcolor(CO_FORE);' \
      '    gputglyph(glyph, 0, 0);' \
      '    gdrawrect(&box);' \
      '    gexit();' \
      '    return 0;' \
      '}' \
      > /tmp/ugpx-smoke.c; \
    xcc /tmp/ugpx-smoke.c -lugpx -o /tmp/ugpx-smoke.com; \
    test -s /tmp/ugpx-smoke.com; \
    sh -lc 'xcc /tmp/ugpx-smoke.c -lugpx -o /tmp/ugpx-login-smoke.com'; \
    test -s /tmp/ugpx-login-smoke.com; \
    ! xcc /tmp/ugpx-smoke.c -lgpx -lugpx -o /tmp/mixed-gpx-smoke.com 2>/dev/null; \
    ! xcc -Wl,-lgpx,-lugpx --version 2>/dev/null; \
    ! xld -lgpx -lugpx --version 2>/dev/null; \
    ! xld /opt/idp/lib/libgpx.a /opt/idp/lib/libugpx.a --version 2>/dev/null; \
    printf '%s\n' 'int main(void) { return 0; }' > /tmp/emu-smoke.c; \
    xcc --platform=emu /tmp/emu-smoke.c -o /tmp/emu-smoke.bin; \
    test -s /tmp/emu-smoke.bin; \
    ! xcc --platform=none /tmp/emu-smoke.c -o /tmp/none-smoke.bin 2>/dev/null; \
    ! xld --platform=none --version 2>/dev/null; \
    printf '\076\021\062\000\040\076\245\323\220\076\042\062\000\040\076\063\062\000\301\076\132\323\210\072\000\040\376\021\040\021\072\000\301\376\063\040\012\333\220\072\000\040\376\042\040\001\166\030\376' \
      > /tmp/partner-bank-smoke.bin; \
    xemu --run --quiet \
      --load-bin /tmp/partner-bank-smoke.bin \
      --origin 0xc000 --pc 0xc000 --max-steps 1000; \
    rm -f \
      /tmp/idp-smoke.c /tmp/idp-smoke.com \
      /tmp/ugpx-smoke.c /tmp/ugpx-smoke.com /tmp/ugpx-login-smoke.com \
      /tmp/mixed-gpx-smoke.com \
      /tmp/emu-smoke.c /tmp/emu-smoke.bin \
      /tmp/none-smoke.bin /tmp/partner-bank-smoke.bin; \
    xcc --version
