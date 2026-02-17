# SDCC Z80-only toolchain with uCsim sz80 (single-stage Alpine)
FROM alpine:3.20

ARG IMG_VERSION=1.0.1
ARG SDCC_VERSION=4.5.0

LABEL org.opencontainers.image.title="sdcc-z80" \
      org.opencontainers.image.description="SDCC Z80-only toolchain with uCsim sz80 (single-stage, includes make/git)." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV PREFIX=/opt/sdcc
ENV PATH="${PREFIX}/bin:${PATH}"

# Build + runtime tools (readline/ncurses for uCsim) + DDD dependencies
RUN apk add --no-cache \
    build-base bison flex zlib-dev boost-dev mawk \
    readline-dev ncurses-dev \
    ca-certificates wget xz bzip2 tar linux-headers \
    make git libstdc++ libgcc \
    readline ncurses \
    motif motif-dev \
    libx11 libx11-dev libxext libxext-dev libxt libxt-dev \
    libxmu libxmu-dev libxpm libxpm-dev libice libice-dev libsm libsm-dev \
    libxau libxau-dev libxdmcp libxdmcp-dev \
    perl texinfo

# Fonts.
RUN apk add --no-cache \
    font-misc-misc font-cursor-misc font-adobe-75dpi font-adobe-100dpi \
    fontconfig ttf-dejavu

# Fetch source
RUN wget -O /tmp/sdcc-src.tar.bz2 \
      "https://sourceforge.net/projects/sdcc/files/sdcc/${SDCC_VERSION}/sdcc-src-${SDCC_VERSION}.tar.bz2/download" \
 && mkdir -p /tmp/src \
 && tar -xjf /tmp/sdcc-src.tar.bz2 -C /tmp/src --strip-components=1

# Patch SDCC Z80 defaults:
# 1) Change default code_loc from 0x200 to 0x100 (standard CP/M TPA)
RUN sed -i 's/options\.code_loc = 0x200/options.code_loc = 0x100/' /tmp/src/src/z80/main.c
# 2) Set default data_loc to 0 instead of 0x8000 (let linker place it after _CODE)
RUN sed -i 's/options\.data_loc = 0x8000/options.data_loc = 0/' /tmp/src/src/z80/main.c
# 3) Guard the Z80 _DATA emission so it's skipped when data_loc is 0
#    (Z80 branch writes it unconditionally, unlike MCS51 which checks)
RUN sed -i 's/WRITE_SEG_LOC ("_DATA", options.data_loc);/if (options.data_loc) { WRITE_SEG_LOC ("_DATA", options.data_loc); }/' /tmp/src/src/SDCCmain.c

# Build SDCC (Z80-only), then explicitly build+install uCsim
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
    # --- explicitly build & install uCsim (some builds only install 'ucsim') ---
    && cd /tmp/src/sim/ucsim \
    && ./configure --prefix="${PREFIX}" --target=z80 --disable-werror \
    && make -j"$(getconf _NPROCESSORS_ONLN)" \
    && make install \
    # --- explicitly build & install sdcdb ---
    #&& cd /tmp/src/debugger; \
    #&& ./configure --prefix="${PREFIX}" --target=z80 --disable-werror; \
    #&& make -j"$(getconf _NPROCESSORS_ONLN)"; \
    #&& make install \
    # --- ensure 'sz80' exists: provide a wrapper selecting the Z80 target ---
    && if [ ! -x "${PREFIX}/bin/sz80" ]; then \
         printf '#!/bin/sh\nexec ucsim -t z80 "$@"\n' > "${PREFIX}/bin/sz80" && chmod +x "${PREFIX}/bin/sz80"; \
       fi \
    # strip ELF binaries to save space
    && find "${PREFIX}/bin" -type f -exec sh -c 'file -b "$1" | grep -q ELF && strip "$1" || true' _ {} \; \
    && rm -rf /tmp/src /tmp/build /tmp/sdcc-src.tar.bz2

# After installing SDCC/uCsim:
RUN ln -sf "${PREFIX}/bin/ucsim_z80" "${PREFIX}/bin/ucsim"

# Build DDD
RUN set -eux; \
    ver=3.4.0; \
    cd /tmp; \
    wget -O ddd-${ver}.tar.gz "https://ftp.gnu.org/gnu/ddd/ddd-${ver}.tar.gz"; \
    tar -xzf ddd-${ver}.tar.gz; \
    cd ddd-${ver}; \
    export CXXFLAGS="-O2 -fpermissive -Wno-deprecated-declarations -Wno-register"; \
    ./configure --prefix=/usr; \
    make -j"$(getconf _NPROCESSORS_ONLN)"; \
    make install; \
    cd /; rm -rf /tmp/ddd-${ver} /tmp/ddd-${ver}.tar.gz

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
    command -v sz80; \
    echo "Checking DDD:"; \
    command -v ddd
