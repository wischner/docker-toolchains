# SDCC Z80-only toolchain with uCsim sz80 (single-stage Alpine)
FROM alpine:3.20

ARG IMG_VERSION=1.0.0
ARG SDCC_VERSION=4.5.0

LABEL org.opencontainers.image.title="sdcc-z80" \
      org.opencontainers.image.description="SDCC Z80-only toolchain with uCsim sz80 (single-stage, includes make/git)." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV PREFIX=/opt/sdcc
ENV PATH="${PREFIX}/bin:${PATH}"

# Build + runtime tools (add ncurses/readline for uCsim)
RUN apk add --no-cache \
    build-base bison flex zlib-dev boost-dev mawk \
    readline-dev ncurses-dev \
    ca-certificates wget xz bzip2 tar linux-headers \
    make git libstdc++ libgcc \
    readline ncurses

# Fetch source
RUN wget -O /tmp/sdcc-src.tar.bz2 \
      "https://sourceforge.net/projects/sdcc/files/sdcc/${SDCC_VERSION}/sdcc-src-${SDCC_VERSION}.tar.bz2/download" \
 && mkdir -p /tmp/src \
 && tar -xjf /tmp/sdcc-src.tar.bz2 -C /tmp/src --strip-components=1

# Configure & build Z80-only (uCsim always enabled)
RUN set -e; \
    mkdir -p /tmp/build; cd /tmp/build; \
    ../src/configure --prefix="${PREFIX}" \
      --disable-werror \
      --enable-ucsim \
      --disable-mcs51-port --disable-ds390-port --disable-ds400-port \
      --disable-hc08-port  --disable-s08-port   --disable-stm8-port \
      --disable-pdk13-port --disable-pdk14-port --disable-pdk15-port \
      --disable-pic14-port --disable-pic16-port \
      --disable-r2k-port   --disable-r3ka-port  \
      --disable-gbz80-port --disable-tlcs90-port --disable-z180-port \
      --disable-mos6502-port --disable-mos65c02-port \
    && make -j"$(getconf _NPROCESSORS_ONLN)" \
    && make install \
    # strip ELF binaries to save space
    && find "${PREFIX}/bin" -type f -exec sh -c 'file -b "$1" | grep -q ELF && strip "$1" || true' _ {} \; \
    && rm -rf /tmp/src /tmp/build /tmp/sdcc-src.tar.bz2

WORKDIR /work

# Sanity check printouts
RUN set -e; \
    echo "=== SDCC installed at ${PREFIX} ==="; \
    sdcc --version; \
    echo "Available -m targets:"; \
    sdcc --help | sed -n 's/^[[:space:]]\(-m[a-z0-9_]\+\).*/\1/p'; \
    echo "Checking Z80 assembler/linker:"; \
    command -v sdasz80 && command -v sdldz80; \
    echo "Checking uCsim sz80:"; \
    command -v sz80
