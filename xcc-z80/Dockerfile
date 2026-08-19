# syntax=docker/dockerfile:1

# XCC Z80 toolchain on lightweight Ubuntu
ARG IMG_VERSION=2.3.2
ARG XYZ_REPO=retro-vault/xyz
ARG XYZ_VERSION=2.3.2

# Build the medium-model toolchain locally. Derived images depend on this image,
# so its build must not require the same version to be published first.
FROM ubuntu:24.04 AS xyz-builder

ARG IMG_VERSION
ARG XYZ_REPO
ARG XYZ_VERSION

RUN set -eux; \
    test "${IMG_VERSION}" = "${XYZ_VERSION}"; \
    apt-get update; \
    apt-get install -y --no-install-recommends binutils ca-certificates g++ git make; \
    rm -rf /var/lib/apt/lists/*; \
    tag="v${XYZ_VERSION#v}"; \
    git clone --depth=1 --branch "${tag}" \
      "https://github.com/${XYZ_REPO}.git" /tmp/xyz; \
    make -C /tmp/xyz/x -j"$(nproc)" x \
      REPO_ROOT=/tmp/xyz \
      Y_ROOT=/tmp/xyz/y \
      BUILD_DIR=/tmp/xyz-build \
      DIST_DIR=/opt/x \
      OUT_DIR=/tmp/xyz-out \
      Z_DIST_DIR=/tmp/xyz-z \
      BUILD=release \
      ENABLE_SANITIZERS=0 \
      X_MODEL=M \
      XCC_VERSION="${XYZ_VERSION#v}" \
      XLD_VERSION="${XYZ_VERSION#v}" \
      XTOOLS_VERSION="${XYZ_VERSION#v}" \
      XOBJCOPY_VERSION="${XYZ_VERSION#v}" \
      PACKAGE_NAME=x-m; \
    rm -rf /opt/x/pkg; \
    printf '%s\n' "${tag}" > /opt/x/.version; \
    printf '%s\n' "https://github.com/${XYZ_REPO}/tree/${tag}" > /opt/x/.source; \
    for tool in xcc xld xas xar xopt xobjcopy xprog xgdb xemu; do \
      test -x "/opt/x/bin/${tool}"; \
      "/opt/x/bin/${tool}" --version | grep -F " ${XYZ_VERSION#v} "; \
    done

FROM ubuntu:24.04

ARG IMG_VERSION=2.3.2
ARG XYZ_REPO=retro-vault/xyz
ARG XYZ_VERSION=2.3.2
LABEL org.opencontainers.image.title="xcc-z80" \
      org.opencontainers.image.description="Ubuntu-based X Compiler Suite medium-model Linux bundle with xcc, xas, xld, xprog, xgdb, xemu, headers, and Z80 runtime libraries." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/home/ubuntu \
    XTOOLS_ROOT=/opt/x \
    PATH="/opt/x/bin:${PATH}"

# Install the source-built medium-model prefix, then preserve previous path and
# command aliases.
COPY --from=xyz-builder /opt/x/ /opt/x/

RUN set -eux; \
    test "${IMG_VERSION}" = "${XYZ_VERSION}"; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl libstdc++6 python3; \
    rm -rf /var/lib/apt/lists/*; \
    test "$(sed 's/^v//' /opt/x/.version)" = "${XYZ_VERSION#v}"; \
    mkdir -p /etc/profile.d; \
    printf '%s\n' 'export PATH=/opt/x/bin:$PATH' > /etc/profile.d/x.sh; \
    chmod 0644 /etc/profile.d/x.sh; \
    ln -sfn /opt/x /opt/xtools; \
    test -x /opt/x/bin/xcc; \
    test -x /opt/x/bin/xas; \
    test -x /opt/x/bin/xld; \
    test -x /opt/x/bin/xprog; \
    test -x /opt/x/bin/xgdb; \
    test -x /opt/x/bin/xemu; \
    if [ ! -e /opt/x/bin/xgdb-z80 ]; then ln -s xemu /opt/x/bin/xgdb-z80; fi; \
    test -f /etc/profile.d/x.sh; \
    test -L /opt/xtools; \
    test -x /opt/x/bin/xgdb-z80; \
    test -x /opt/xtools/bin/xcc; \
    test -f /opt/x/z80/lib/crt0.rel; \
    test -f /opt/x/z80/lib/crt0-cpm3.rel; \
    test -f /opt/x/z80/lib/libc.a; \
    test -f /opt/x/z80/lib/libruntime.a; \
    test -f /opt/x/z80/lib/linker.ld; \
    test -f /opt/x/z80/lib/linker-cpm3.ld; \
    test -f /opt/x/z80/lib/crt0-zx-ram.rel; \
    test -f /opt/x/z80/lib/crt0-zx-rom.rel; \
    test -f /opt/x/z80/lib/libzx-ram.a; \
    test -f /opt/x/z80/lib/libzx-rom.a; \
    test -f /opt/x/z80/lib/linker-zx-ram.ld; \
    test -f /opt/x/z80/lib/linker-zx-rom.ld

RUN mkdir -p /work && chown -R ubuntu:ubuntu /work /home/ubuntu

USER ubuntu
WORKDIR /work

# Sanity checks using the installed package tools directly.
RUN set -eux; \
    test "$(id -u)" -ne 0; \
    echo 'int main(void){return 0;}' > /tmp/hello.c; \
    printf '%s\n' \
      '#include <stdio.h>' \
      '#include <stdlib.h>' \
      '_Static_assert(__STDC_VERSION__ >= 202311L, "C23");' \
      '_Static_assert(sizeof(long) == 4, "long");' \
      '_Static_assert(sizeof(float) == 4, "float");' \
      'int main(void) {' \
      '    volatile long n = strtol("42", 0, 10);' \
      '    volatile float f = 3.5f;' \
      '    char buf[32];' \
      '    snprintf(buf, sizeof buf, "%ld", n);' \
      '    if (f < 3.0f) return 1;' \
      '    return buf[0] == '\''4'\'' ? 0 : 1;' \
      '}' \
      > /tmp/medium-model.c; \
    xcc /tmp/hello.c -o /tmp/hello.xl; \
    xcc /tmp/medium-model.c -o /tmp/medium-model.xl; \
    xcc -c /tmp/hello.c -o /tmp/hello.rel; \
    xcc --oformat=binary -Ttext=0x8000 /tmp/hello.c -o /tmp/hello.bin; \
    test -s /tmp/hello.bin; \
    test -s /tmp/medium-model.xl; \
    test -s /tmp/hello.rel; \
    test -s /tmp/hello.xl; \
    command -v xcc; \
    command -v xas; \
    command -v xld; \
    command -v xar; \
    command -v xopt; \
    command -v xobjcopy; \
    command -v xprog; \
    command -v xgdb; \
    command -v xemu; \
    command -v xgdb-z80; \
    xgdb --help >/dev/null; \
    xemu --help >/dev/null; \
    xprog --help >/dev/null; \
    xcc --version; \
    rm -f /tmp/hello.c /tmp/medium-model.c /tmp/hello.rel /tmp/hello.xl /tmp/medium-model.xl /tmp/hello.bin
