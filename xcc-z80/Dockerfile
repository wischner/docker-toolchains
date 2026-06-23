# XCC Z80 toolchain on lightweight Ubuntu
FROM ubuntu:24.04

ARG IMG_VERSION=1.7.2
LABEL org.opencontainers.image.title="xcc-z80" \
      org.opencontainers.image.description="Ubuntu-based XYZ Debian package with xcc, xas, xld, xgdb, headers, and Z80 runtime libraries." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/home/ubuntu \
    XTOOLS_ROOT=/opt/x \
    PATH="/opt/x/bin:${PATH}"

COPY sdk/x.deb /tmp/x.deb

# Install the upstream Debian package, then preserve the previous prefix as a symlink.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends /tmp/x.deb; \
    rm -rf /var/lib/apt/lists/* /tmp/x.deb; \
    ln -s /opt/x /opt/xtools; \
    test -x /opt/x/bin/xcc; \
    test -x /opt/x/bin/xas; \
    test -x /opt/x/bin/xld; \
    test -x /opt/x/bin/xgdb; \
    test -f /etc/profile.d/x.sh; \
    test -L /opt/xtools; \
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
    xcc /tmp/hello.c -o /tmp/hello.xl; \
    xcc -c /tmp/hello.c -o /tmp/hello.rel; \
    xcc --oformat=binary -Ttext=0x8000 /tmp/hello.c -o /tmp/hello.bin; \
    test -s /tmp/hello.bin; \
    test -s /tmp/hello.rel; \
    test -s /tmp/hello.xl; \
    command -v xcc; \
    command -v xas; \
    command -v xld; \
    command -v xar; \
    command -v xopt; \
    command -v xobjcopy; \
    command -v xgdb; \
    command -v xgdb-z80; \
    xcc --version; \
    rm -f /tmp/hello.c /tmp/hello.rel /tmp/hello.xl /tmp/hello.bin
