# Iskra Delta Partner (IDP) Z80 toolchain on Alpine:
# - Base: sdcc-z80 (Alpine, includes SDCC + uCsim)
# - Adds: cpmtools for CP/M disk image creation
# - Adds: Partner-specific libraries, crt0.rel, and include files
ARG BASE_IMAGE=wischner/sdcc-z80:latest
FROM ${BASE_IMAGE}

ARG IMG_VERSION=1.0.0

LABEL org.opencontainers.image.title="sdcc-z80-idp" \
      org.opencontainers.image.description="SDCC Z80 toolchain for Iskra Delta Partner with cpmtools" \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

# Install dependencies for building cpmtools
RUN apk add --no-cache git build-base autoconf automake

# Build and install cpmtools from source
RUN set -e; \
    git clone --depth=1 https://github.com/lipro-cpm4l/cpmtools.git /tmp/cpmtools; \
    cd /tmp/cpmtools; \
    ./configure --prefix=/usr --without-libdsk || ./configure --prefix=/usr; \
    make -j$(nproc) || make; \
    make install; \
    rm -rf /tmp/cpmtools

# Create directory structure for Partner files
RUN mkdir -p /opt/partner/lib /opt/partner/include

# Copy Partner-specific runtime library (crt0.rel)
COPY partner/crt0.rel /opt/partner/lib/

# Copy Partner-specific libraries
COPY partner/lib/ /opt/partner/lib/

# Copy Partner-specific include files
COPY partner/include/ /opt/partner/include/

# Set environment variables for Partner development
ENV PARTNER_HOME=/opt/partner
ENV PARTNER_LIB=/opt/partner/lib
ENV PARTNER_INCLUDE=/opt/partner/include

# Add Partner paths to compiler search paths (initialize C_INCLUDE_PATH if not set)
ENV C_INCLUDE_PATH=/opt/partner/include

# Create convenience wrapper for Partner compilation
RUN printf '%s\n' \
    '#!/bin/sh' \
    '# Compile for Iskra Delta Partner with proper paths' \
    'exec sdcc -mz80 \' \
    '  -I${PARTNER_INCLUDE} \' \
    '  -L${PARTNER_LIB} \' \
    '  ${PARTNER_LIB}/crt0.rel \' \
    '  "$@"' \
    > /usr/local/bin/idp-sdcc && chmod +x /usr/local/bin/idp-sdcc

# Set work dir
WORKDIR /work

# Sanity checks
RUN set -e; \
    echo "== Iskra Delta Partner (IDP) Z80 Toolchain =="; \
    sdcc --version | head -n1; \
    echo "cpmtools:"; \
    cpmcp --help 2>&1 | head -n1 || echo "cpmcp available"; \
    echo "Partner libraries:"; \
    ls -lh ${PARTNER_LIB}; \
    echo "Partner includes:"; \
    ls -lh ${PARTNER_INCLUDE}; \
    which idp-sdcc
