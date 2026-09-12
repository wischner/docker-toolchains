# syntax=docker/dockerfile:1

ARG BASE_IMAGE=wischner/xcc-z80:2.10.0

# Assemble the current ZX Spectrum target libraries with XCC itself.
FROM ${BASE_IMAGE} AS library-builder

ARG LIBGPX_REF=main
ARG LIBSQUID_REF=main

USER root

# Remote Git ADDs are deliberately used for moving refs: BuildKit resolves the
# ref on each build and invalidates the layer when its commit changes.
ADD --keep-git-dir=true https://github.com/retro-vault/libgpx.git#${LIBGPX_REF} /tmp/libgpx
ADD --keep-git-dir=true https://github.com/retro-plastics/libsquid.git#${LIBSQUID_REF} /tmp/libsquid

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends git; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p \
      /opt/zx-spectrum/include \
      /opt/zx-spectrum/lib \
      /opt/zx-spectrum/share/licenses/libgpx \
      /opt/zx-spectrum/share/metadata \
      /tmp/libgpx-obj; \
    test -d /tmp/libgpx/src/zx; \
    test -d /tmp/libgpx/src/common; \
    for src in /tmp/libgpx/src/zx/*.s /tmp/libgpx/src/common/*.s; do \
      name="$(basename "${src}" .s)"; \
      xas -g -o "/tmp/libgpx-obj/${name}.rel" "${src}"; \
    done; \
    xar --mode=gnu rcs /opt/zx-spectrum/lib/libgpx.a /tmp/libgpx-obj/*.rel; \
    for member in gpx_draw_box gpx_draw_circle gpx_fill_circle gpx_draw_polygon gpx_fill_polygon; do \
      xar t /opt/zx-spectrum/lib/libgpx.a | grep -qx "${member}.rel"; \
    done; \
    ln -s libgpx.a /opt/zx-spectrum/lib/libgpx.lib; \
    install -m 0644 /tmp/libgpx/include/libgpx.h /opt/zx-spectrum/include/libgpx.h; \
    install -m 0644 /tmp/libgpx/LICENSE /opt/zx-spectrum/share/licenses/libgpx/LICENSE; \
    git -C /tmp/libgpx rev-parse HEAD > /opt/zx-spectrum/share/metadata/libgpx.version; \
    printf '%s\n' 'https://github.com/retro-vault/libgpx' > /opt/zx-spectrum/share/metadata/libgpx.source; \
    test -s /opt/zx-spectrum/lib/libgpx.a

# libsquid's own build script is the only supported way to produce the Z80
# archive: it verifies the C/asm wire contract, links a real program against
# the archive it just wrote, and enforces the backend's code-size ceiling.
# zx-ram and zx-rom emit identical objects, so one archive serves both.
RUN set -eux; \
    mkdir -p \
      /opt/zx-spectrum/include/squid \
      /opt/zx-spectrum/share/doc/libsquid; \
    cd /tmp/libsquid; \
    sh scripts/check-wire.sh; \
    sh scripts/build-z80.sh zx-ram /tmp/libsquid-build /tmp/libsquid-out; \
    install -m 0644 /tmp/libsquid-out/lib/libsquid.a /opt/zx-spectrum/lib/libsquid.a; \
    ln -s libsquid.a /opt/zx-spectrum/lib/libsquid.lib; \
    install -m 0644 /tmp/libsquid-out/include/squid/*.h /opt/zx-spectrum/include/squid/; \
    install -m 0644 /tmp/libsquid/README.md /opt/zx-spectrum/share/doc/libsquid/README.md; \
    install -m 0644 /tmp/libsquid-out/TOOLCHAIN /opt/zx-spectrum/share/metadata/libsquid.toolchain; \
    git -C /tmp/libsquid rev-parse HEAD > /opt/zx-spectrum/share/metadata/libsquid.version; \
    printf '%s\n' 'https://github.com/retro-plastics/libsquid' > /opt/zx-spectrum/share/metadata/libsquid.source; \
    test -s /opt/zx-spectrum/lib/libsquid.a; \
    test -f /opt/zx-spectrum/include/squid/snet.h; \
    test -f /opt/zx-spectrum/include/squid/socket.h; \
    rm -rf /tmp/libsquid-build /tmp/libsquid-out

# Build current host-side Spectrum utilities independently of the target
# compiler prefix, and install each under a self-contained /opt directory.
FROM ubuntu:24.04 AS host-tools-builder

ARG BEEPOLIX_REF=main
ARG ZX_SPECTRUM_MCP_REF=main
ARG SNATCH_REF=main
ARG HDFMONKEY_REF=master

ADD --keep-git-dir=true https://github.com/retro-vault/beepolix.git#${BEEPOLIX_REF} /tmp/beepolix
ADD --keep-git-dir=true https://github.com/retro-vault/zx-spectrum-mcp.git#${ZX_SPECTRUM_MCP_REF} /tmp/zx-spectrum-mcp
ADD --keep-git-dir=true https://github.com/retro-vault/snatch.git#${SNATCH_REF} /tmp/snatch
ADD --keep-git-dir=true https://github.com/gasman/hdfmonkey.git#${HDFMONKEY_REF} /tmp/hdfmonkey

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      autoconf automake build-essential ca-certificates cmake git \
      libasound2-dev libcairo2-dev libfontconfig1-dev libpng-dev pkg-config; \
    rm -rf /var/lib/apt/lists/*; \
    export CXXFLAGS='-std=c++17 -Wall -Wextra -pedantic -O2 -DNDEBUG -I/tmp/beepolix/include -I/tmp/beepolix/lib/ay8910 -I/tmp/beepolix/lib/z80cpu -I.'; \
    export CFLAGS='-std=c11 -Wall -Wextra -pedantic -O2 -DNDEBUG -I/tmp/beepolix/lib/ay8910 -I/tmp/beepolix/lib/z80cpu -I.'; \
    export LDFLAGS=''; \
    make -C /tmp/beepolix -j"$(nproc)" src; \
    mkdir -p /opt/beepolix/bin /opt/beepolix/share/licenses/beepolix /opt/beepolix/share/doc/beepolix; \
    install -m 0755 /tmp/beepolix/bin/beplay /tmp/beepolix/bin/bescore /tmp/beepolix/bin/becompile /opt/beepolix/bin/; \
    install -m 0644 /tmp/beepolix/LICENSE /opt/beepolix/share/licenses/beepolix/LICENSE; \
    install -m 0644 /tmp/beepolix/README.md /opt/beepolix/share/doc/beepolix/README.md; \
    git -C /tmp/beepolix rev-parse HEAD > /opt/beepolix/.version; \
    printf '%s\n' 'https://github.com/retro-vault/beepolix' > /opt/beepolix/.source; \
    unset CXXFLAGS CFLAGS LDFLAGS; \
    make -C /tmp/zx-spectrum-mcp -j"$(nproc)" release; \
    make -C /tmp/zx-spectrum-mcp install PREFIX=/opt/zx-spectrum-mcp; \
    git -C /tmp/zx-spectrum-mcp rev-parse HEAD > /opt/zx-spectrum-mcp/.version; \
    printf '%s\n' 'https://github.com/retro-vault/zx-spectrum-mcp' > /opt/zx-spectrum-mcp/.source; \
    cmake -S /tmp/snatch -B /tmp/snatch-build \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING=OFF \
      -DCMAKE_INSTALL_PREFIX=/opt/snatch; \
    cmake --build /tmp/snatch-build -j"$(nproc)"; \
    mkdir -p \
      /opt/snatch/bin \
      /opt/snatch/lib/snatch/plugins \
      /opt/snatch/share/licenses/snatch \
      /opt/snatch/share/doc/snatch; \
    install -m 0755 /tmp/snatch/bin/snatch /opt/snatch/bin/snatch; \
    install -m 0755 /tmp/snatch/bin/plugins/*.so /opt/snatch/lib/snatch/plugins/; \
    install -m 0644 /tmp/snatch/LICENSE /opt/snatch/share/licenses/snatch/LICENSE; \
    install -m 0644 /tmp/snatch/README.md /opt/snatch/share/doc/snatch/README.md; \
    git -C /tmp/snatch rev-parse HEAD > /opt/snatch/.version; \
    printf '%s\n' 'https://github.com/retro-vault/snatch' > /opt/snatch/.source; \
    # hdfmonkey: FAT12/16/32 tooling for HDF and raw IDE images used by divIDE,
    # DivMMC, and esxDOS. Plain autotools, no external dependencies.
    cd /tmp/hdfmonkey; \
    autoreconf -fi; \
    ./configure --prefix=/opt/hdfmonkey; \
    make -j"$(nproc)"; \
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
    # Ready-made empty FAT16 HDF volumes for esxDOS. They are almost entirely
    # zeros, so they are stored gzip-compressed; gunzip one to get a disk.
    for size in 16M 32M 64M 128M; do \
      image="/opt/hdfmonkey/share/hdfmonkey/images/blank-$(printf '%s' "${size}" | tr 'M' 'm').hdf"; \
      /opt/hdfmonkey/bin/hdfmonkey create --fat16 "${image}" "${size}" ESXDOS; \
      /opt/hdfmonkey/bin/hdfmonkey ls "${image}" >/dev/null; \
      gzip -9 -n "${image}"; \
      test -s "${image}.gz"; \
    done; \
    cd /; \
    test -x /opt/beepolix/bin/beplay; \
    test -x /opt/beepolix/bin/bescore; \
    test -x /opt/beepolix/bin/becompile; \
    test -x /opt/zx-spectrum-mcp/bin/zx-spectrum-mcp; \
    test -x /opt/snatch/bin/snatch; \
    test -n "$(find /opt/snatch/lib/snatch/plugins -maxdepth 1 -name '*.so' -print -quit)"; \
    test ! -e /opt/snatch/include; \
    test -x /opt/hdfmonkey/bin/hdfmonkey; \
    test -f /opt/hdfmonkey/share/hdfmonkey/images/blank-16m.hdf.gz; \
    test -f /opt/hdfmonkey/share/hdfmonkey/images/blank-128m.hdf.gz

FROM ${BASE_IMAGE}

ARG IMG_VERSION=2.10.0
ARG XYZ_VERSION=2.5.1
ARG LIBGPX_REF=main
ARG LIBSQUID_REF=main
ARG BEEPOLIX_REF=main
ARG ZX_SPECTRUM_MCP_REF=main
ARG SNATCH_REF=main
ARG HDFMONKEY_REF=master

LABEL org.opencontainers.image.title="xcc-z80-zx-spectrum" \
      org.opencontainers.image.description="Medium-model XCC Z80 toolchain with ZX Spectrum RAM/ROM and esxDOS targets, libgpx, libsquid, Beepolix, ZX Spectrum MCP, snatch, and hdfmonkey." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later AND GPL-3.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/home/ubuntu \
    XTOOLS_ROOT=/opt/x \
    ZX_SPECTRUM_ROOT=/opt/zx-spectrum \
    LIBGPX_INCLUDE_DIR=/opt/zx-spectrum/include \
    LIBGPX_LIB_DIR=/opt/zx-spectrum/lib \
    BEEPOLIX_ROOT=/opt/beepolix \
    ZX_SPECTRUM_MCP_ROOT=/opt/zx-spectrum-mcp \
    ZX_SPECTRUM_MCP_ROM=/opt/zx-spectrum-mcp/share/zx-spectrum-mcp/roms/48.rom \
    SNATCH_ROOT=/opt/snatch \
    SNATCH_PLUGIN_DIR=/opt/snatch/lib/snatch/plugins \
    HDFMONKEY_ROOT=/opt/hdfmonkey \
    HDFMONKEY_IMAGE_DIR=/opt/hdfmonkey/share/hdfmonkey/images \
    PATH="/usr/local/bin:/opt/x/bin:${PATH}"

USER root

COPY --from=library-builder /opt/zx-spectrum/ /opt/zx-spectrum/
COPY --from=host-tools-builder /opt/beepolix/ /opt/beepolix/
COPY --from=host-tools-builder /opt/zx-spectrum-mcp/ /opt/zx-spectrum-mcp/
COPY --from=host-tools-builder /opt/snatch/ /opt/snatch/
COPY --from=host-tools-builder /opt/hdfmonkey/ /opt/hdfmonkey/
COPY --chmod=0755 xcc-zx-spectrum /usr/local/bin/xcc
COPY --chmod=0755 xld-zx-spectrum /usr/local/bin/xld
COPY libraries.manifest /opt/zx-spectrum/libraries.manifest

RUN set -eux; \
    test "$(sed 's/^v//' /opt/x/.version)" = "${XYZ_VERSION#v}"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      libasound2t64 libcairo2 libfontconfig1 libpng16-16t64; \
    rm -rf /var/lib/apt/lists/*; \
    ln -s /opt/zx-spectrum/include/libgpx.h /opt/x/z80/include/libgpx.h; \
    ln -s /opt/zx-spectrum/lib/libgpx.a /opt/x/z80/lib/libgpx.a; \
    ln -s /opt/zx-spectrum/lib/libgpx.lib /opt/x/z80/lib/libgpx.lib; \
    ln -s /opt/zx-spectrum/include/squid /opt/x/z80/include/squid; \
    ln -s /opt/zx-spectrum/lib/libsquid.a /opt/x/z80/lib/libsquid.a; \
    ln -s /opt/zx-spectrum/lib/libsquid.lib /opt/x/z80/lib/libsquid.lib; \
    ln -s /opt/beepolix/bin/beplay /usr/local/bin/beplay; \
    ln -s /opt/beepolix/bin/bescore /usr/local/bin/bescore; \
    ln -s /opt/beepolix/bin/becompile /usr/local/bin/becompile; \
    ln -s /opt/zx-spectrum-mcp/bin/zx-spectrum-mcp /usr/local/bin/zx-spectrum-mcp; \
    ln -s /opt/snatch/bin/snatch /usr/local/bin/snatch; \
    ln -s /opt/hdfmonkey/bin/hdfmonkey /usr/local/bin/hdfmonkey; \
    printf '%s\n' 'export PATH=/usr/local/bin:/opt/x/bin:$PATH' > /etc/profile.d/x.sh; \
    printf '%s\n' 'export SNATCH_PLUGIN_DIR=/opt/snatch/lib/snatch/plugins' >> /etc/profile.d/x.sh; \
    printf '%s\n' 'export HDFMONKEY_IMAGE_DIR=/opt/hdfmonkey/share/hdfmonkey/images' >> /etc/profile.d/x.sh; \
    chmod 0644 /etc/profile.d/x.sh; \
    test -f /opt/x/z80/include/libgpx.h; \
    test -f /opt/x/z80/lib/libgpx.a; \
    test -f /opt/x/z80/include/squid/snet.h; \
    test -f /opt/x/z80/lib/libsquid.a; \
    for zx in zx-ram zx-rom zx-esxdos zx-esxdos-rom; do \
      test -f "/opt/x/z80/lib/crt0-${zx}.rel"; \
      test -f "/opt/x/z80/lib/lib${zx}.a"; \
      test -f "/opt/x/z80/lib/linker-${zx}.ld"; \
    done; \
    test -f "${ZX_SPECTRUM_MCP_ROM}"; \
    test -d "${SNATCH_PLUGIN_DIR}"; \
    test -d "${HDFMONKEY_IMAGE_DIR}"; \
    for tool in xcc xld xas xar xopt xobjcopy xprog xgdb xemu beplay bescore becompile zx-spectrum-mcp snatch hdfmonkey; do \
      command -v "${tool}"; \
    done

USER ubuntu
WORKDIR /work

# Validate the default RAM target, the explicit ROM and esxDOS targets, libgpx
# and libsquid discovery, Spectrum tape and esxDOS disk packaging, hdfmonkey,
# and every added host command as the runtime user.
RUN set -eux; \
    test "$(id -u)" -ne 0; \
    test "$(command -v xcc)" = /usr/local/bin/xcc; \
    test "$(command -v xld)" = /usr/local/bin/xld; \
    test "$(command -v hdfmonkey)" = /usr/local/bin/hdfmonkey; \
    printf '%s\n' \
      '#include <libgpx.h>' \
      'int main(void) {' \
      '    gpx_t *gpx = gpx_create(GPXM_DEFAULT);' \
      '    rect_t box = { 8, 8, 40, 24 };' \
      '    gpx_draw_pixel(gpx, 1, 1, CO_FORE, BM_CPY, 0);' \
      '    gpx_draw_circle(gpx, 64, 64, 20, CO_FORE, BM_CPY, 0);' \
      '    gpx_draw_box(gpx, &box, GPX_EDGE_ALL, CO_FORE, BM_CPY, GPX_LP_SOLID, 0);' \
      '    return gpx == 0;' \
      '}' \
      > /tmp/zx-gpx-smoke.c; \
    xcc -Os --oformat=binary /tmp/zx-gpx-smoke.c -lgpx -o /tmp/zx-gpx-smoke.bin; \
    xprog --tap /tmp/zx-gpx-smoke.bin -o /tmp/zx-gpx-smoke.tap --name GPXSMOKE; \
    xcc -Os --platform=zx-rom --oformat=binary /tmp/zx-gpx-smoke.c -lgpx -o /tmp/zx-gpx-smoke.rom; \
    test -s /tmp/zx-gpx-smoke.bin; \
    test -s /tmp/zx-gpx-smoke.tap; \
    test "$(wc -c < /tmp/zx-gpx-smoke.rom)" -eq 16384; \
    printf '%s\n' \
      '#include <fcntl.h>' \
      '#include <unistd.h>' \
      '#include <libgpx.h>' \
      'int main(void) {' \
      '    gpx_t *gpx = gpx_create(GPXM_DEFAULT);' \
      '    int fd = open("SMOKE.TXT", O_WRONLY | O_CREAT | O_TRUNC);' \
      '    if (fd < 0) return 1;' \
      '    write(fd, "ok", 2);' \
      '    close(fd);' \
      '    return gpx == 0;' \
      '}' \
      > /tmp/zx-esxdos-smoke.c; \
    xcc -Os --platform=zx-esxdos --oformat=binary /tmp/zx-esxdos-smoke.c -lgpx -o /tmp/zx-esxdos-smoke.bin; \
    xcc -Os --platform=zx-esxdos-rom --oformat=binary /tmp/zx-esxdos-smoke.c -lgpx -o /tmp/zx-esxdos-smoke.rom; \
    test -s /tmp/zx-esxdos-smoke.bin; \
    test "$(wc -c < /tmp/zx-esxdos-smoke.rom)" -eq 16384; \
    xprog --esxdos /tmp/zx-esxdos-smoke.bin --name SMOKE.BIN -o /tmp/zx-esxdos-smoke.ide; \
    test "$(wc -c < /tmp/zx-esxdos-smoke.ide)" -eq 16777216; \
    hdfmonkey ls /tmp/zx-esxdos-smoke.ide | grep -F SMOKE.BIN; \
    hdfmonkey create --fat16 /tmp/zx-smoke.hdf 16M SMOKE; \
    hdfmonkey mkdir /tmp/zx-smoke.hdf /BIN; \
    hdfmonkey put /tmp/zx-smoke.hdf /tmp/zx-esxdos-smoke.bin /BIN/SMOKE.BIN; \
    hdfmonkey ls /tmp/zx-smoke.hdf /BIN | grep -F SMOKE.BIN; \
    hdfmonkey get /tmp/zx-smoke.hdf /BIN/SMOKE.BIN /tmp/zx-smoke-roundtrip.bin; \
    cmp /tmp/zx-esxdos-smoke.bin /tmp/zx-smoke-roundtrip.bin; \
    gunzip -c "${HDFMONKEY_IMAGE_DIR}/blank-16m.hdf.gz" > /tmp/zx-blank.hdf; \
    hdfmonkey put /tmp/zx-blank.hdf /tmp/zx-esxdos-smoke.bin /SMOKE.BIN; \
    hdfmonkey ls /tmp/zx-blank.hdf | grep -F SMOKE.BIN; \
    printf '%s\n' \
      '#include <stdint.h>' \
      '#include <stdlib.h>' \
      '#include <squid/snet.h>' \
      '#include <squid/socket.h>' \
      'static int snd(uint8_t c) { (void)c; return 0; }' \
      'static int rcv(void) { return -1; }' \
      'static uint8_t tick(void) { return 0; }' \
      'int main(void) {' \
      '    squid_platform_t plat;' \
      '    squid_timing_t tm;' \
      '    int fd;' \
      '    plat.send_char = snd;' \
      '    plat.recv_char = rcv;' \
      '    plat.get_tick = tick;' \
      '    plat.mem_alloc = malloc;' \
      '    plat.mem_free = free;' \
      '    tm.timeout_ticks = 6;' \
      '    tm.ack_delay_ticks = 2;' \
      '    tm.ping_ticks = 0;' \
      '    tm.max_retries = 3;' \
      '    tm.payload_bytes = 0;' \
      '    snet_init(&plat, &tm);' \
      '    snet_burst();' \
      '    fd = squid_open(32, 32);' \
      '    if (fd > 0) squid_close(fd);' \
      '    return snet_link_is_up() ? 1 : 0;' \
      '}' \
      > /tmp/zx-squid-smoke.c; \
    xcc -Os --oformat=binary /tmp/zx-squid-smoke.c -lsquid -o /tmp/zx-squid-smoke.bin; \
    test -s /tmp/zx-squid-smoke.bin; \
    beplay --help >/dev/null; \
    bescore --help >/dev/null; \
    becompile --help >/dev/null; \
    zx-spectrum-mcp --version; \
    zx-spectrum-mcp --list-tools >/dev/null; \
    snatch --help >/dev/null; \
    hdfmonkey help >/dev/null; \
    ! xcc --platform=cpm3 --version >/dev/null 2>&1; \
    ! xld --platform=none --version >/dev/null 2>&1; \
    rm -f /tmp/zx-gpx-smoke.c /tmp/zx-gpx-smoke.bin /tmp/zx-gpx-smoke.tap /tmp/zx-gpx-smoke.rom \
      /tmp/zx-squid-smoke.c /tmp/zx-squid-smoke.bin \
      /tmp/zx-esxdos-smoke.c /tmp/zx-esxdos-smoke.bin /tmp/zx-esxdos-smoke.rom \
      /tmp/zx-esxdos-smoke.ide /tmp/zx-smoke.hdf /tmp/zx-smoke-roundtrip.bin /tmp/zx-blank.hdf; \
    xcc --version
