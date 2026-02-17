# Iskra Delta Partner (IDP) Z80 toolchain on Alpine:
# - Base: sdcc-z80 (Alpine, includes SDCC + uCsim)
# - Adds: cpmtools for CP/M disk image creation
# - Replaces SDCC default Z80 includes/libs with library bundles synced into ./libraries
ARG BASE_IMAGE=wischner/sdcc-z80:latest
FROM ${BASE_IMAGE}

ARG IMG_VERSION=1.0.0

LABEL org.opencontainers.image.title="sdcc-z80-idp" \
      org.opencontainers.image.description="SDCC Z80 toolchain for Iskra Delta Partner with cpmtools and wrapped SDCC Z80 runtime" \
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

# Copy synced library bundles payload
COPY libraries/ /opt/libraries/
COPY local-libraries/ /opt/local-libraries/

# Replace SDCC default Z80 include/lib directories with bundled content
RUN set -e; \
    SDCC_BASE=/opt/sdcc/share/sdcc; \
    INC_DIR=${SDCC_BASE}/include; \
    LIB_DIR=${SDCC_BASE}/lib/z80; \
    TMP_DIR=/tmp/merge-z80-lib; \
    mkdir -p "${INC_DIR}" "${LIB_DIR}" "${TMP_DIR}/obj"; \
    find "${INC_DIR}" -mindepth 1 -delete; \
    find "${LIB_DIR}" -mindepth 1 -delete; \
    bundle_count=0; \
    lib_count=0; \
    for root in /opt/libraries /opt/local-libraries; do \
      [ -d "${root}" ] || continue; \
      for bundle in "${root}"/*; do \
        [ -d "${bundle}" ] || continue; \
        bundle_count=$((bundle_count + 1)); \
        if [ -d "${bundle}/include" ]; then \
          cp -a "${bundle}/include/." "${INC_DIR}/"; \
        fi; \
        for lib in "${bundle}"/lib/*.lib; do \
          [ -f "${lib}" ] || continue; \
          lib_count=$((lib_count + 1)); \
          extract_dir="${TMP_DIR}/extract-${lib_count}"; \
          mkdir -p "${extract_dir}"; \
          ( cd "${extract_dir}" && sdar -x "${lib}" ); \
          find "${extract_dir}" -type f -name '*.rel' -exec cp {} "${TMP_DIR}/obj/" \; ; \
        done; \
      done; \
    done; \
    [ "${bundle_count}" -gt 0 ] || { echo "No bundles found in /opt/libraries or /opt/local-libraries"; exit 1; }; \
    CRT0="$(find /opt/libraries /opt/local-libraries -type f -name 'crt0.rel' | sort | head -n1 || true)"; \
    [ -n "${CRT0}" ] || { echo "No crt0.rel found in synced bundles"; exit 1; }; \
    cp "${CRT0}" "${LIB_DIR}/crt0.rel"; \
    if find "${TMP_DIR}/obj" -type f -name '*.rel' | grep -q .; then \
      sdar -rc "${LIB_DIR}/z80.lib" "${TMP_DIR}"/obj/*.rel; \
    else \
      echo "No .rel members extracted from bundled .lib files"; \
      exit 1; \
    fi; \
    rm -rf "${TMP_DIR}"

# Create convenience wrapper for Partner compilation
RUN printf '%s\n' \
    '#!/bin/sh' \
    '# Compile for Iskra Delta Partner using wrapped SDCC defaults' \
    'exec sdcc -mz80 "$@"' \
    > /usr/local/bin/idp-sdcc && chmod +x /usr/local/bin/idp-sdcc

# Set work dir
WORKDIR /work

# Sanity checks
RUN set -e; \
    echo "== Iskra Delta Partner (IDP) Z80 Toolchain =="; \
    sdcc --version | head -n1; \
    echo "cpmtools:"; \
    cpmcp --help 2>&1 | head -n1 || echo "cpmcp available"; \
    echo "Wrapped SDCC include dir:"; \
    ls -lh /opt/sdcc/share/sdcc/include | head -n 20; \
    echo "Wrapped SDCC lib dir:"; \
    ls -lh /opt/sdcc/share/sdcc/lib/z80 | grep -E 'crt0.rel|z80.lib|^total'; \
    which idp-sdcc
