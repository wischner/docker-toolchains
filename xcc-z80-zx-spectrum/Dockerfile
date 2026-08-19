# syntax=docker/dockerfile:1

ARG BASE_IMAGE=wischner/xcc-z80:2.3.2

# Assemble the current ZX Spectrum libgpx backend with XCC itself.
FROM ${BASE_IMAGE} AS libgpx-builder

ARG LIBGPX_REF=main

USER root

# Remote Git ADDs are deliberately used for moving refs: BuildKit resolves the
# ref on each build and invalidates the layer when its commit changes.
ADD --keep-git-dir=true https://github.com/retro-vault/libgpx.git#${LIBGPX_REF} /tmp/libgpx

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
    for src in /tmp/libgpx/src/zx/*.s; do \
      name="$(basename "${src}" .s)"; \
      xas -g -o "/tmp/libgpx-obj/${name}.rel" "${src}"; \
    done; \
    xar --mode=gnu rcs /opt/zx-spectrum/lib/libgpx.a /tmp/libgpx-obj/*.rel; \
    ln -s libgpx.a /opt/zx-spectrum/lib/libgpx.lib; \
    install -m 0644 /tmp/libgpx/include/libgpx.h /opt/zx-spectrum/include/libgpx.h; \
    install -m 0644 /tmp/libgpx/LICENSE /opt/zx-spectrum/share/licenses/libgpx/LICENSE; \
    git -C /tmp/libgpx rev-parse HEAD > /opt/zx-spectrum/share/metadata/libgpx.version; \
    printf '%s\n' 'https://github.com/retro-vault/libgpx' > /opt/zx-spectrum/share/metadata/libgpx.source; \
    test -s /opt/zx-spectrum/lib/libgpx.a

# Build current host-side Spectrum utilities independently of the target
# compiler prefix, and install each under a self-contained /opt directory.
FROM ubuntu:24.04 AS host-tools-builder

ARG BEEPOLIX_REF=main
ARG ZX_SPECTRUM_MCP_REF=main
ARG SNATCH_REF=main

ADD --keep-git-dir=true https://github.com/retro-vault/beepolix.git#${BEEPOLIX_REF} /tmp/beepolix
ADD --keep-git-dir=true https://github.com/retro-vault/zx-spectrum-mcp.git#${ZX_SPECTRUM_MCP_REF} /tmp/zx-spectrum-mcp
ADD --keep-git-dir=true https://github.com/retro-vault/snatch.git#${SNATCH_REF} /tmp/snatch

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      build-essential ca-certificates cmake git \
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
    test -x /opt/beepolix/bin/beplay; \
    test -x /opt/beepolix/bin/bescore; \
    test -x /opt/beepolix/bin/becompile; \
    test -x /opt/zx-spectrum-mcp/bin/zx-spectrum-mcp; \
    test -x /opt/snatch/bin/snatch; \
    test -n "$(find /opt/snatch/lib/snatch/plugins -maxdepth 1 -name '*.so' -print -quit)"; \
    test ! -e /opt/snatch/include

FROM ${BASE_IMAGE}

ARG IMG_VERSION=2.3.2
ARG XYZ_VERSION=2.3.2
ARG LIBGPX_REF=main
ARG BEEPOLIX_REF=main
ARG ZX_SPECTRUM_MCP_REF=main
ARG SNATCH_REF=main

LABEL org.opencontainers.image.title="xcc-z80-zx-spectrum" \
      org.opencontainers.image.description="Medium-model XCC Z80 toolchain with ZX Spectrum RAM/ROM targets, libgpx, Beepolix, ZX Spectrum MCP, and snatch." \
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
    PATH="/usr/local/bin:/opt/x/bin:${PATH}"

USER root

COPY --from=libgpx-builder /opt/zx-spectrum/ /opt/zx-spectrum/
COPY --from=host-tools-builder /opt/beepolix/ /opt/beepolix/
COPY --from=host-tools-builder /opt/zx-spectrum-mcp/ /opt/zx-spectrum-mcp/
COPY --from=host-tools-builder /opt/snatch/ /opt/snatch/
COPY --chmod=0755 xcc-zx-spectrum /usr/local/bin/xcc
COPY --chmod=0755 xld-zx-spectrum /usr/local/bin/xld
COPY libraries.manifest /opt/zx-spectrum/libraries.manifest

RUN set -eux; \
    test "${IMG_VERSION}" = "${XYZ_VERSION}"; \
    test "$(sed 's/^v//' /opt/x/.version)" = "${XYZ_VERSION#v}"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      libasound2t64 libcairo2 libfontconfig1 libpng16-16t64; \
    rm -rf /var/lib/apt/lists/*; \
    ln -s /opt/zx-spectrum/include/libgpx.h /opt/x/z80/include/libgpx.h; \
    ln -s /opt/zx-spectrum/lib/libgpx.a /opt/x/z80/lib/libgpx.a; \
    ln -s /opt/zx-spectrum/lib/libgpx.lib /opt/x/z80/lib/libgpx.lib; \
    ln -s /opt/beepolix/bin/beplay /usr/local/bin/beplay; \
    ln -s /opt/beepolix/bin/bescore /usr/local/bin/bescore; \
    ln -s /opt/beepolix/bin/becompile /usr/local/bin/becompile; \
    ln -s /opt/zx-spectrum-mcp/bin/zx-spectrum-mcp /usr/local/bin/zx-spectrum-mcp; \
    ln -s /opt/snatch/bin/snatch /usr/local/bin/snatch; \
    printf '%s\n' 'export PATH=/usr/local/bin:/opt/x/bin:$PATH' > /etc/profile.d/x.sh; \
    printf '%s\n' 'export SNATCH_PLUGIN_DIR=/opt/snatch/lib/snatch/plugins' >> /etc/profile.d/x.sh; \
    chmod 0644 /etc/profile.d/x.sh; \
    test -f /opt/x/z80/include/libgpx.h; \
    test -f /opt/x/z80/lib/libgpx.a; \
    test -f "${ZX_SPECTRUM_MCP_ROM}"; \
    test -d "${SNATCH_PLUGIN_DIR}"; \
    for tool in xcc xld xas xar xopt xobjcopy xprog xgdb xemu beplay bescore becompile zx-spectrum-mcp snatch; do \
      command -v "${tool}"; \
    done

USER ubuntu
WORKDIR /work

# Validate the default RAM target, explicit ROM target, libgpx discovery,
# Spectrum tape packaging, and every added host command as the runtime user.
RUN set -eux; \
    test "$(id -u)" -ne 0; \
    test "$(command -v xcc)" = /usr/local/bin/xcc; \
    test "$(command -v xld)" = /usr/local/bin/xld; \
    printf '%s\n' \
      '#include <libgpx.h>' \
      'int main(void) {' \
      '    gpx_t *gpx = gpx_create(GPXM_DEFAULT);' \
      '    gpx_draw_pixel(gpx, 1, 1, CO_FORE, BM_CPY, 0);' \
      '    return gpx == 0;' \
      '}' \
      > /tmp/zx-gpx-smoke.c; \
    xcc -Os --oformat=binary /tmp/zx-gpx-smoke.c -lgpx -o /tmp/zx-gpx-smoke.bin; \
    xprog --tap /tmp/zx-gpx-smoke.bin -o /tmp/zx-gpx-smoke.tap --name GPXSMOKE; \
    xcc -Os --platform=zx-rom --oformat=binary /tmp/zx-gpx-smoke.c -lgpx -o /tmp/zx-gpx-smoke.rom; \
    test -s /tmp/zx-gpx-smoke.bin; \
    test -s /tmp/zx-gpx-smoke.tap; \
    test "$(wc -c < /tmp/zx-gpx-smoke.rom)" -eq 16384; \
    beplay --help >/dev/null; \
    bescore --help >/dev/null; \
    becompile --help >/dev/null; \
    zx-spectrum-mcp --version; \
    zx-spectrum-mcp --list-tools >/dev/null; \
    snatch --help >/dev/null; \
    ! xcc --platform=cpm3 --version >/dev/null 2>&1; \
    ! xld --platform=none --version >/dev/null 2>&1; \
    rm -f /tmp/zx-gpx-smoke.c /tmp/zx-gpx-smoke.bin /tmp/zx-gpx-smoke.tap /tmp/zx-gpx-smoke.rom; \
    xcc --version
