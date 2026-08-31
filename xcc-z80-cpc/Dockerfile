# syntax=docker/dockerfile:1

ARG BASE_IMAGE=wischner/xcc-z80:2.8.0

# Assemble the current Amstrad CPC libgpx backend with XCC itself.
#
# The CPC backend is bare-metal: its own crt0-cpc.s takes the machine at
# 0x8000 with the firmware never having run, and gpx_create() pages both ROMs
# out. It therefore cannot be linked against the firmware-hosted cpc-464,
# cpc-664, or cpc-6128 platforms, and is installed under its own prefix rather
# than onto XCC's default search path.
FROM ${BASE_IMAGE} AS libgpx-builder

ARG LIBGPX_REF=v0.4.0

USER root

# Remote Git ADDs are deliberately used for moving refs: BuildKit resolves the
# ref on each build and invalidates the layer when its commit changes.
ADD --keep-git-dir=true https://github.com/retro-vault/libgpx.git#${LIBGPX_REF} /tmp/libgpx

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends git; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p \
      /opt/cpc/include \
      /opt/cpc/lib \
      /opt/cpc/share/licenses/libgpx \
      /opt/cpc/share/metadata \
      /tmp/libgpx-obj; \
    test -d /tmp/libgpx/src/cpc; \
    for src in /tmp/libgpx/src/cpc/*.s; do \
      name="$(basename "${src}" .s)"; \
      xas -g -I /tmp/libgpx/src/cpc -o "/tmp/libgpx-obj/${name}.rel" "${src}"; \
    done; \
    test -f /tmp/libgpx-obj/crt0-cpc.rel; \
    install -m 0644 /tmp/libgpx-obj/crt0-cpc.rel /opt/cpc/lib/crt0-cpc.rel; \
    rm -f /tmp/libgpx-obj/crt0-cpc.rel; \
    xar --mode=gnu rcs /opt/cpc/lib/libgpx.a /tmp/libgpx-obj/*.rel; \
    ln -s libgpx.a /opt/cpc/lib/libgpx.lib; \
    install -m 0644 /tmp/libgpx/include/libgpx.h /opt/cpc/include/libgpx.h; \
    install -m 0644 /tmp/libgpx/LICENSE /opt/cpc/share/licenses/libgpx/LICENSE; \
    git -C /tmp/libgpx rev-parse HEAD > /opt/cpc/share/metadata/libgpx.version; \
    printf '%s\n' 'https://github.com/retro-vault/libgpx' > /opt/cpc/share/metadata/libgpx.source; \
    test -s /opt/cpc/lib/libgpx.a; \
    test -s /opt/cpc/lib/crt0-cpc.rel

# Build Martine, the CPC image and sprite converter, with its own Go toolchain
# so the final image carries only the resulting binary.
#
# Martine's CLI entry point imports Fyne unconditionally, so it must be built
# with CGO against the GL/X11 headers. The binary itself runs headless; the
# final image carries only the corresponding shared libraries.
FROM golang:1.25-bookworm AS martine-builder

ARG MARTINE_REF=master

ADD --keep-git-dir=true https://github.com/jeromelesaux/martine.git#${MARTINE_REF} /tmp/martine

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      libgl1-mesa-dev libx11-dev libxcursor-dev libxi-dev libxinerama-dev \
      libxrandr-dev libxxf86vm-dev pkg-config; \
    rm -rf /var/lib/apt/lists/*; \
    cd /tmp/martine; \
    CGO_ENABLED=1 go build -trimpath -ldflags='-s -w' -o /tmp/martine-bin/martine ./cmd/martine; \
    mkdir -p /opt/martine/bin /opt/martine/share/licenses/martine /opt/martine/share/doc/martine; \
    install -m 0755 /tmp/martine-bin/martine /opt/martine/bin/martine; \
    install -m 0644 /tmp/martine/LICENCE.md /opt/martine/share/licenses/martine/LICENCE.md; \
    install -m 0644 /tmp/martine/README.md /opt/martine/share/doc/martine/README.md; \
    git -C /tmp/martine rev-parse HEAD > /opt/martine/.version; \
    printf '%s\n' 'https://github.com/jeromelesaux/martine' > /opt/martine/.source; \
    test -x /opt/martine/bin/martine

# Build the current host-side CPC utilities independently of the target
# compiler prefix, and install each under a self-contained /opt directory.
FROM ubuntu:24.04 AS host-tools-builder

ARG AMSTRAD_CPC_MCP_REF=main
ARG SNATCH_REF=main
ARG IDSK_REF=master
ARG SALVADOR_REF=main
ARG APULTRA_REF=master

ADD --keep-git-dir=true https://github.com/retro-vault/amstrad-cpc-mcp.git#${AMSTRAD_CPC_MCP_REF} /tmp/amstrad-cpc-mcp
ADD --keep-git-dir=true https://github.com/retro-vault/snatch.git#${SNATCH_REF} /tmp/snatch
ADD --keep-git-dir=true https://github.com/cpcsdk/idsk.git#${IDSK_REF} /tmp/idsk
ADD --keep-git-dir=true https://github.com/emmanuel-marty/salvador.git#${SALVADOR_REF} /tmp/salvador
ADD --keep-git-dir=true https://github.com/emmanuel-marty/apultra.git#${APULTRA_REF} /tmp/apultra

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      build-essential ca-certificates cmake curl git \
      libcairo2-dev libfontconfig1-dev libpng-dev pkg-config; \
    rm -rf /var/lib/apt/lists/*; \
    # amstrad-cpc-mcp: fetch the redistributable English firmware ROMs, then
    # build and install the emulator/MCP server.
    make -C /tmp/amstrad-cpc-mcp roms; \
    make -C /tmp/amstrad-cpc-mcp -j"$(nproc)" release; \
    make -C /tmp/amstrad-cpc-mcp install PREFIX=/opt/amstrad-cpc-mcp; \
    git -C /tmp/amstrad-cpc-mcp rev-parse HEAD > /opt/amstrad-cpc-mcp/.version; \
    printf '%s\n' 'https://github.com/retro-vault/amstrad-cpc-mcp' > /opt/amstrad-cpc-mcp/.source; \
    # snatch: asset extraction and conversion pipeline.
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
    # iDSK: read, list, extract, and populate AMSDOS .dsk images.
    cmake -S /tmp/idsk -B /tmp/idsk-build -DCMAKE_BUILD_TYPE=Release; \
    cmake --build /tmp/idsk-build -j"$(nproc)"; \
    mkdir -p /opt/idsk/bin /opt/idsk/share/licenses/idsk /opt/idsk/share/doc/idsk; \
    install -m 0755 /tmp/idsk-build/iDSK /opt/idsk/bin/iDSK; \
    install -m 0644 /tmp/idsk/COPYING /opt/idsk/share/licenses/idsk/COPYING; \
    install -m 0644 /tmp/idsk/README.md /opt/idsk/share/doc/idsk/README.md; \
    git -C /tmp/idsk rev-parse HEAD > /opt/idsk/.version; \
    printf '%s\n' 'https://github.com/cpcsdk/idsk' > /opt/idsk/.source; \
    # salvador (ZX0) and apultra (aPLib): the two compressors CPC loaders and
    # demos most commonly pair with a Z80 decruncher. Both Makefiles hardcode
    # CC=clang, so the compiler is overridden on the command line.
    mkdir -p \
      /opt/cpc-compress/bin \
      /opt/cpc-compress/share/licenses/salvador \
      /opt/cpc-compress/share/licenses/apultra \
      /opt/cpc-compress/share/asm/salvador \
      /opt/cpc-compress/share/asm/apultra; \
    make -C /tmp/salvador -j"$(nproc)" CC=gcc; \
    install -m 0755 /tmp/salvador/salvador /opt/cpc-compress/bin/salvador; \
    install -m 0644 /tmp/salvador/LICENSE /opt/cpc-compress/share/licenses/salvador/LICENSE; \
    cp -a /tmp/salvador/asm/. /opt/cpc-compress/share/asm/salvador/; \
    git -C /tmp/salvador rev-parse HEAD > /opt/cpc-compress/.salvador.version; \
    make -C /tmp/apultra -j"$(nproc)" CC=gcc; \
    install -m 0755 /tmp/apultra/apultra /opt/cpc-compress/bin/apultra; \
    install -m 0644 /tmp/apultra/LICENSE /opt/cpc-compress/share/licenses/apultra/LICENSE; \
    cp -a /tmp/apultra/asm/. /opt/cpc-compress/share/asm/apultra/; \
    git -C /tmp/apultra rev-parse HEAD > /opt/cpc-compress/.apultra.version; \
    printf '%s\n' 'https://github.com/emmanuel-marty/salvador https://github.com/emmanuel-marty/apultra' \
      > /opt/cpc-compress/.source; \
    test -x /opt/amstrad-cpc-mcp/bin/amstrad-cpc-mcp; \
    test -x /opt/snatch/bin/snatch; \
    test -n "$(find /opt/snatch/lib/snatch/plugins -maxdepth 1 -name '*.so' -print -quit)"; \
    test -x /opt/idsk/bin/iDSK; \
    test -x /opt/cpc-compress/bin/salvador; \
    test -x /opt/cpc-compress/bin/apultra

FROM ${BASE_IMAGE}

ARG IMG_VERSION=2.8.0
ARG XYZ_VERSION=2.5.0
ARG LIBGPX_REF=v0.4.0
ARG AMSTRAD_CPC_MCP_REF=main
ARG SNATCH_REF=main
ARG IDSK_REF=master
ARG MARTINE_REF=master
ARG SALVADOR_REF=main
ARG APULTRA_REF=master

LABEL org.opencontainers.image.title="xcc-z80-cpc" \
      org.opencontainers.image.description="Medium-model XCC Z80 toolchain with Amstrad CPC 464/664/6128 firmware targets, CDT and DSK packaging, libgpx, Amstrad CPC MCP, and the standard CPC disk, graphics, and compression tools." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later AND GPL-3.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/home/ubuntu \
    XTOOLS_ROOT=/opt/x \
    CPC_ROOT=/opt/cpc \
    LIBGPX_INCLUDE_DIR=/opt/cpc/include \
    LIBGPX_LIB_DIR=/opt/cpc/lib \
    LIBGPX_CPC_CRT0=/opt/cpc/lib/crt0-cpc.rel \
    AMSTRAD_CPC_MCP_ROOT=/opt/amstrad-cpc-mcp \
    AMSTRAD_CPC_MCP_ROMS=/opt/amstrad-cpc-mcp/share/amstrad-cpc-mcp/roms \
    MARTINE_ROOT=/opt/martine \
    IDSK_ROOT=/opt/idsk \
    CPC_COMPRESS_ROOT=/opt/cpc-compress \
    SNATCH_ROOT=/opt/snatch \
    SNATCH_PLUGIN_DIR=/opt/snatch/lib/snatch/plugins \
    PATH="/usr/local/bin:/opt/x/bin:${PATH}"

USER root

COPY --from=libgpx-builder /opt/cpc/ /opt/cpc/
COPY --from=host-tools-builder /opt/amstrad-cpc-mcp/ /opt/amstrad-cpc-mcp/
COPY --from=host-tools-builder /opt/snatch/ /opt/snatch/
COPY --from=host-tools-builder /opt/idsk/ /opt/idsk/
COPY --from=host-tools-builder /opt/cpc-compress/ /opt/cpc-compress/
COPY --from=martine-builder /opt/martine/ /opt/martine/
COPY libraries.manifest /opt/cpc/libraries.manifest

RUN set -eux; \
    test "$(sed 's/^v//' /opt/x/.version)" = "${XYZ_VERSION#v}"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      libcairo2 libfontconfig1 libpng16-16t64 libdsk-utils \
      libgl1 libx11-6 libxcursor1 libxi6 libxinerama1 libxrandr2 libxxf86vm1; \
    rm -rf /var/lib/apt/lists/*; \
    ln -s /opt/amstrad-cpc-mcp/bin/amstrad-cpc-mcp /usr/local/bin/amstrad-cpc-mcp; \
    ln -s /opt/snatch/bin/snatch /usr/local/bin/snatch; \
    ln -s /opt/idsk/bin/iDSK /usr/local/bin/iDSK; \
    ln -s /opt/idsk/bin/iDSK /usr/local/bin/idsk; \
    ln -s /opt/martine/bin/martine /usr/local/bin/martine; \
    ln -s /opt/cpc-compress/bin/salvador /usr/local/bin/salvador; \
    ln -s /opt/cpc-compress/bin/apultra /usr/local/bin/apultra; \
    printf '%s\n' 'export PATH=/usr/local/bin:/opt/x/bin:$PATH' > /etc/profile.d/x.sh; \
    printf '%s\n' 'export SNATCH_PLUGIN_DIR=/opt/snatch/lib/snatch/plugins' >> /etc/profile.d/x.sh; \
    printf '%s\n' 'export CPC_ROOT=/opt/cpc' >> /etc/profile.d/x.sh; \
    chmod 0644 /etc/profile.d/x.sh; \
    test -f /opt/cpc/include/libgpx.h; \
    test -f /opt/cpc/lib/libgpx.a; \
    test -f /opt/cpc/lib/crt0-cpc.rel; \
    test -d "${SNATCH_PLUGIN_DIR}"; \
    for tool in xcc xld xas xar xopt xobjcopy xprog xgdb xemu \
                amstrad-cpc-mcp snatch iDSK martine salvador apultra \
                dsktrans dskid; do \
      command -v "${tool}"; \
    done

RUN mkdir -p /work && chown -R ubuntu:ubuntu /work /home/ubuntu

USER ubuntu
WORKDIR /work

# Validate all three firmware-hosted CPC platforms, CDT and DSK packaging, the
# bare-metal libgpx link path, and every added host command as the runtime user.
RUN set -eux; \
    test "$(id -u)" -ne 0; \
    echo 'int main(void){return 0;}' > /tmp/cpc-smoke.c; \
    for cpc in cpc-464 cpc-664 cpc-6128; do \
      xcc -Os "--platform=${cpc}" --oformat=binary /tmp/cpc-smoke.c \
        -o "/tmp/cpc-smoke-${cpc}.bin"; \
      test -s "/tmp/cpc-smoke-${cpc}.bin"; \
    done; \
    xprog --cdt /tmp/cpc-smoke-cpc-464.bin --name SMOKE -o /tmp/cpc-smoke.cdt; \
    xprog --dsk /tmp/cpc-smoke-cpc-6128.bin --name SMOKE.BIN -o /tmp/cpc-smoke.dsk; \
    test -s /tmp/cpc-smoke.cdt; \
    test -s /tmp/cpc-smoke.dsk; \
    iDSK /tmp/cpc-smoke.dsk -l | grep -i SMOKE; \
    dskid /tmp/cpc-smoke.dsk >/dev/null; \
    printf '%s\n' \
      '#include <libgpx.h>' \
      'int main(void) {' \
      '    gpx_t *gpx = gpx_create(GPXM_CPC_640X200);' \
      '    gpx_draw_pixel(gpx, 1, 1, CO_FORE, BM_CPY, 0);' \
      '    return gpx == 0;' \
      '}' \
      > /tmp/cpc-gpx-smoke.c; \
    xcc -mz80 -std=c11 -Os -I/opt/cpc/include -c /tmp/cpc-gpx-smoke.c \
      -o /tmp/cpc-gpx-smoke.rel; \
    xld --oformat=binary -b _CODE=0x8000 -nostartfiles \
      -o /tmp/cpc-gpx-smoke.bin \
      /opt/cpc/lib/crt0-cpc.rel /tmp/cpc-gpx-smoke.rel /opt/cpc/lib/libgpx.a; \
    test -s /tmp/cpc-gpx-smoke.bin; \
    amstrad-cpc-mcp --version; \
    amstrad-cpc-mcp --list-tools >/dev/null; \
    martine -help 2>&1 | grep -qi 'Amstrad'; \
    salvador /tmp/cpc-smoke-cpc-464.bin /tmp/cpc-smoke.zx0; \
    apultra /tmp/cpc-smoke-cpc-464.bin /tmp/cpc-smoke.apl; \
    test -s /tmp/cpc-smoke.zx0; \
    test -s /tmp/cpc-smoke.apl; \
    snatch --help >/dev/null; \
    rm -f /tmp/cpc-smoke.c /tmp/cpc-gpx-smoke.c /tmp/cpc-gpx-smoke.rel \
      /tmp/cpc-gpx-smoke.bin /tmp/cpc-smoke-cpc-464.bin /tmp/cpc-smoke-cpc-664.bin \
      /tmp/cpc-smoke-cpc-6128.bin /tmp/cpc-smoke.cdt /tmp/cpc-smoke.dsk \
      /tmp/cpc-smoke.zx0 /tmp/cpc-smoke.apl; \
    xcc --version
