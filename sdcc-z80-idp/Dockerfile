# Iskra Delta Partner (IDP) Z80 toolchain on Alpine:
# - Base: sdcc-z80 (Alpine, includes SDCC + uCsim)
# - Adds: cpmdisk for Partner-compatible CP/M disk image creation
# - Replaces SDCC default Z80 includes/libs with library bundles synced into ./libraries
ARG BASE_IMAGE=wischner/sdcc-z80:latest
FROM ${BASE_IMAGE}

ARG IMG_VERSION=1.0.0
ARG CPMDISK_VERSION=latest
ARG SNATCH_VERSION=latest

LABEL org.opencontainers.image.title="sdcc-z80-idp" \
      org.opencontainers.image.description="SDCC Z80 toolchain for Iskra Delta Partner with cpmdisk and wrapped SDCC Z80 runtime" \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

# Install dependencies for installing cpmdisk, snatch, and handling library sync
RUN apk add --no-cache git build-base curl libstdc++ gcompat

# Build and install cpmdisk from latest (or pinned) GitHub release tag
RUN set -e; \
    if [ "${CPMDISK_VERSION}" = "latest" ]; then \
      rel_url="https://api.github.com/repos/iskra-delta/cpmdisk/releases/latest"; \
    else \
      rel_url="https://api.github.com/repos/iskra-delta/cpmdisk/releases/tags/${CPMDISK_VERSION}"; \
    fi; \
    rel_json="$(curl -fsSL "${rel_url}")"; \
    tag="$(printf '%s\n' "${rel_json}" | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"; \
    [ -n "${tag}" ] || { echo "Could not resolve cpmdisk release tag"; exit 1; }; \
    apk add --no-cache cmake; \
    git clone --depth=1 --branch "${tag}" https://github.com/iskra-delta/cpmdisk.git /tmp/cpmdisk; \
    cmake -S /tmp/cpmdisk -B /tmp/cpmdisk/build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr; \
    cmake --build /tmp/cpmdisk/build -j"$(nproc)"; \
    install -m 0755 /tmp/cpmdisk/bin/cpmdisk /usr/local/bin/cpmdisk; \
    install -m 0755 /tmp/cpmdisk/bin/libcpmdisk.so /usr/lib/libcpmdisk.so; \
    rm -rf /tmp/cpmdisk

# Install snatch from latest (or pinned) GitHub release into /opt/snatch
RUN set -e; \
    if [ "${SNATCH_VERSION}" = "latest" ]; then \
      rel_url="https://api.github.com/repos/retro-vault/snatch/releases/latest"; \
    else \
      rel_url="https://api.github.com/repos/retro-vault/snatch/releases/tags/${SNATCH_VERSION}"; \
    fi; \
    rel_json="$(curl -fsSL "${rel_url}")"; \
    tag="$(printf '%s\n' "${rel_json}" | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"; \
    asset_url="$(printf '%s\n' "${rel_json}" | sed -n 's/.*"browser_download_url":[[:space:]]*"\([^"]*snatch-linux-x86_64[^"]*\.tar\.gz\)".*/\1/p' | head -n1)"; \
    [ -n "${tag}" ] || { echo "Could not resolve snatch release tag"; exit 1; }; \
    [ -n "${asset_url}" ] || { echo "Could not resolve snatch Linux release asset"; exit 1; }; \
    tmp_dir="$(mktemp -d)"; \
    curl -fsSL -o "${tmp_dir}/snatch.tar.gz" "${asset_url}"; \
    mkdir -p /opt/snatch; \
    tar -xzf "${tmp_dir}/snatch.tar.gz" -C "${tmp_dir}"; \
    src_dir="$(find "${tmp_dir}" -mindepth 1 -maxdepth 1 -type d -name 'snatch-*-linux-x86_64' | head -n1)"; \
    [ -n "${src_dir}" ] || { echo "Could not locate extracted snatch payload"; rm -rf "${tmp_dir}"; exit 1; }; \
    cp -a "${src_dir}/." /opt/snatch/; \
    ln -sf /opt/snatch/snatch /usr/local/bin/snatch; \
    printf '%s\n' "${tag}" > /opt/snatch/.version; \
    rm -rf "${tmp_dir}"

ENV PATH="/opt/sdcc/bin:/opt/snatch:${PATH}" \
    SNATCH_PLUGIN_DIR="/opt/snatch/plugins"

# Copy synced library bundles payload
COPY libraries/ /opt/libraries/

# Build any source-based bundles, then replace SDCC default Z80 include/lib directories
RUN set -e; \
    SDCC_BASE=/opt/sdcc/share/sdcc; \
    INC_DIR=${SDCC_BASE}/include; \
    LIB_DIR=${SDCC_BASE}/lib/z80; \
    TMP_DIR=/tmp/merge-z80-lib; \
    mkdir -p "${INC_DIR}" "${LIB_DIR}" "${TMP_DIR}/obj"; \
    for bundle in /opt/libraries/*; do \
      [ -d "${bundle}" ] || continue; \
      [ -d "${bundle}/src" ] || continue; \
      lib_name="$(basename "${bundle}")"; \
      build_dir="${TMP_DIR}/build-${lib_name}"; \
      mkdir -p "${build_dir}" "${bundle}/lib"; \
      make -C "${bundle}/src" \
        ROOT="${bundle}" \
        BUILD_DIR="${build_dir}" \
        CC=sdcc \
        CFLAGS="--std-c11 -mz80 --debug --no-std-crt0 --nostdinc --nostdlib -I${SDCC_BASE}/include -I${bundle}/include/gpx -I${bundle}/src" \
        AS=sdasz80 \
        ASFLAGS="-xlos -g" \
        AR=sdar \
        ARFLAGS="-rc"; \
      install -m 0644 "${build_dir}/${lib_name}.lib" "${bundle}/lib/${lib_name}.lib"; \
    done; \
    find "${INC_DIR}" -mindepth 1 -delete; \
    find "${LIB_DIR}" -mindepth 1 -delete; \
    bundle_count=0; \
    lib_count=0; \
    for root in /opt/libraries; do \
      [ -d "${root}" ] || continue; \
      for bundle in "${root}"/*; do \
        [ -d "${bundle}" ] || continue; \
        bundle_count=$((bundle_count + 1)); \
        if [ -d "${bundle}/include" ]; then \
          cp -a "${bundle}/include/." "${INC_DIR}/"; \
        fi; \
        merge_policy="$(cat "${bundle}/.merge_policy" 2>/dev/null || printf '%s' merge)"; \
        for lib in "${bundle}"/lib/*.lib; do \
          [ -f "${lib}" ] || continue; \
          if [ "${merge_policy}" = "separate" ]; then \
            cp "${lib}" "${LIB_DIR}/"; \
            continue; \
          fi; \
          lib_count=$((lib_count + 1)); \
          extract_dir="${TMP_DIR}/extract-${lib_count}"; \
          mkdir -p "${extract_dir}"; \
          ( cd "${extract_dir}" && sdar -x "${lib}" ); \
          find "${extract_dir}" -type f -name '*.rel' -exec cp {} "${TMP_DIR}/obj/" \; ; \
        done; \
      done; \
    done; \
    [ "${bundle_count}" -gt 0 ] || { echo "No bundles found in /opt/libraries"; exit 1; }; \
    CRT0="$(find /opt/libraries -type f -name 'crt0.rel' | sort | head -n1 || true)"; \
    if [ -z "${CRT0}" ]; then \
      CRT0="$(find /opt/libraries -type f -name 'crt0*.rel' | sort | head -n1 || true)"; \
    fi; \
    [ -n "${CRT0}" ] || { echo "No crt0.rel found in synced bundles"; exit 1; }; \
    cp "${CRT0}" "${LIB_DIR}/crt0.rel"; \
    if find "${TMP_DIR}/obj" -type f -name '*.rel' | grep -q .; then \
      sdar -rc "${LIB_DIR}/z80.lib" "${TMP_DIR}"/obj/*.rel; \
    else \
      echo "No .rel members extracted from bundled .lib files"; \
      exit 1; \
    fi; \
    rm -rf "${TMP_DIR}"

# Set work dir
WORKDIR /work

# Sanity checks
RUN set -e; \
    echo "== Iskra Delta Partner (IDP) Z80 Toolchain =="; \
    sdcc --version | head -n1; \
    echo "cpmdisk:"; \
    cpmdisk --help 2>&1 | head -n2; \
    echo "snatch:"; \
    snatch --help 2>&1 | head -n4; \
    echo "Wrapped SDCC include dir:"; \
    ls -lh /opt/sdcc/share/sdcc/include | head -n 20; \
    echo "Wrapped SDCC lib dir:"; \
    ls -lh /opt/sdcc/share/sdcc/lib/z80 | grep -E 'crt0.rel|z80.lib|ugpx.lib|^total'; \
    test -x /opt/snatch/snatch; \
    test -d /opt/snatch/plugins; \
    test -f /opt/sdcc/share/sdcc/include/gpx/ugpx.h; \
    test -f /opt/sdcc/share/sdcc/lib/z80/ugpx.lib
