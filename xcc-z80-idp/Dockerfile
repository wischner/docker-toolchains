# XCC Z80 for Iskra Delta Partner
ARG BASE_IMAGE=wischner/xcc-z80:1.9.2
FROM ${BASE_IMAGE}

ARG IMG_VERSION=1.0.1

LABEL org.opencontainers.image.title="xcc-z80-idp" \
      org.opencontainers.image.description="XCC Z80 toolchain scaffold for Iskra Delta Partner layered on the packaged XYZ compiler suite." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV IDP_ROOT=/opt/idp \
    IDP_INCLUDE_DIR=/opt/idp/include \
    IDP_LIB_DIR=/opt/idp/lib \
    IDP_STAGING_DIR=/opt/idp/libraries

USER root

# Reserve Partner-specific install roots for follow-on library layers.
RUN set -eux; \
    mkdir -p "${IDP_INCLUDE_DIR}" "${IDP_LIB_DIR}" "${IDP_STAGING_DIR}"; \
    chown -R ubuntu:ubuntu "${IDP_ROOT}"

COPY --chown=ubuntu:ubuntu libraries.manifest /opt/idp/libraries.manifest

USER ubuntu
WORKDIR /work

# Sanity checks for the inherited XCC toolchain plus the IDP staging roots.
RUN set -eux; \
    test "$(id -u)" -ne 0; \
    command -v xcc; \
    command -v xas; \
    command -v xld; \
    command -v xgdb; \
    command -v xemu; \
    command -v xgdb-z80; \
    test -d "${IDP_INCLUDE_DIR}"; \
    test -d "${IDP_LIB_DIR}"; \
    test -d "${IDP_STAGING_DIR}"; \
    test -f /opt/idp/libraries.manifest; \
    xcc --version
