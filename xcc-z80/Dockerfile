# XCC Z80 toolchain on lightweight Ubuntu
FROM ubuntu:24.04

ARG IMG_VERSION=1.9.4
ARG XYZ_REPO=retro-vault/xyz
ARG XYZ_VERSION=v1.9.4
ARG X_DIST=x-l-linux.zip
LABEL org.opencontainers.image.title="xcc-z80" \
      org.opencontainers.image.description="Ubuntu-based X Compiler Suite large-model Linux bundle with xcc, xas, xld, xgdb, xemu, headers, and Z80 runtime libraries." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/home/ubuntu \
    XTOOLS_ROOT=/opt/x \
    PATH="/opt/x/bin:${PATH}"

# Install the upstream large-model Linux bundle, then preserve previous path and command aliases.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl libasan8 libstdc++6 libubsan1 unzip; \
    rm -rf /var/lib/apt/lists/*; \
    if [ "${XYZ_VERSION}" = "latest" ]; then \
      rel_json="$(curl -fsSL "https://api.github.com/repos/${XYZ_REPO}/releases/latest")"; \
      tag="$(printf '%s\n' "${rel_json}" | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"; \
    else \
      tag="${XYZ_VERSION}"; \
    fi; \
    [ -n "${tag}" ] || { echo "Could not resolve X Compiler Suite release tag"; exit 1; }; \
    asset_url="https://github.com/${XYZ_REPO}/releases/download/${tag}/${X_DIST}"; \
    bundle_dir="/tmp/${X_DIST%.zip}"; \
    curl -fsSL -o /tmp/x.zip "${asset_url}"; \
    unzip -q /tmp/x.zip -d /tmp; \
    test -d "${bundle_dir}"; \
    rm -rf /opt/x; \
    mkdir -p /opt/x /etc/profile.d; \
    cp -a "${bundle_dir}/." /opt/x/; \
    printf '%s\n' 'export PATH=/opt/x/bin:$PATH' > /etc/profile.d/x.sh; \
    chmod 0644 /etc/profile.d/x.sh; \
    printf '%s\n' "${tag}" > /opt/x/.version; \
    printf '%s\n' "${asset_url}" > /opt/x/.source; \
    rm -rf /tmp/x.zip "${bundle_dir}"; \
    ln -sfn /opt/x /opt/xtools; \
    test -x /opt/x/bin/xcc; \
    test -x /opt/x/bin/xas; \
    test -x /opt/x/bin/xld; \
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
    test -f /opt/x/z80/lib/linker-cpm3.ld

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
      '_Static_assert(sizeof(long long) == 8, "long long");' \
      '_Static_assert(sizeof(double) == 8, "double");' \
      'int main(void) {' \
      '    volatile long long n = strtoll("42", 0, 10);' \
      '    volatile double d = strtod("3.5", 0);' \
      '    char buf[32];' \
      '    snprintf(buf, sizeof buf, "%lld %.1f", n, d);' \
      '    return buf[0] == '\''4'\'' ? 0 : 1;' \
      '}' \
      > /tmp/full-model.c; \
    xcc /tmp/hello.c -o /tmp/hello.xl; \
    xcc /tmp/full-model.c -o /tmp/full-model.xl; \
    xcc -c /tmp/hello.c -o /tmp/hello.rel; \
    xcc --oformat=binary -Ttext=0x8000 /tmp/hello.c -o /tmp/hello.bin; \
    test -s /tmp/hello.bin; \
    test -s /tmp/full-model.xl; \
    test -s /tmp/hello.rel; \
    test -s /tmp/hello.xl; \
    command -v xcc; \
    command -v xas; \
    command -v xld; \
    command -v xar; \
    command -v xopt; \
    command -v xobjcopy; \
    command -v xgdb; \
    command -v xemu; \
    command -v xgdb-z80; \
    xgdb --help >/dev/null; \
    xemu --help >/dev/null; \
    xcc --version; \
    rm -f /tmp/hello.c /tmp/full-model.c /tmp/hello.rel /tmp/hello.xl /tmp/full-model.xl /tmp/hello.bin
