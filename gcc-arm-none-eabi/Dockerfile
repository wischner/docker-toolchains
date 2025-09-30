# ARM bare-metal toolchain (arm-none-eabi) + OpenOCD on Alpine (single-stage)
FROM alpine:3.20

ARG IMG_VERSION=1.0.1
# xPack GNU Arm Embedded GCC (change these if you want a different version/build)
ARG XPACK_VER=v13.2.1-1.1
ARG XPACK_TARBALL=xpack-arm-none-eabi-gcc-13.2.1-1.1-linux-x64.tar.gz
ARG XPACK_URL=https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/download/${XPACK_VER}/${XPACK_TARBALL}

LABEL org.opencontainers.image.title="gcc-arm-none-eabi" \
      org.opencontainers.image.description="ARM bare-metal toolchain (arm-none-eabi) with OpenOCD, CMake, git on Alpine (single-stage)." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later and others; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV TOOLCHAIN_DIR=/opt/arm-none-eabi
ENV PATH="${TOOLCHAIN_DIR}/bin:${PATH}"

# Runtime tools & libs
# - openocd (Alpine package) to avoid building from source in single stage
# - usbutils for lsusb; libusb & hidapi for adapter support
# - cmake/make/git for common builds
# - libstdc++ needed by toolchain binaries
RUN apk add --no-cache \
      ca-certificates wget tar xz \
      openocd usbutils libusb hidapi \
      cmake make git bash \
      libstdc++

# Install xPack GNU Arm Embedded GCC (includes arm-none-eabi-gdb)
RUN set -e; \
    mkdir -p /tmp/xpack && cd /tmp/xpack; \
    echo "Fetching ${XPACK_URL}"; \
    wget -q "${XPACK_URL}"; \
    tar -xzf "${XPACK_TARBALL}"; \
    # Move into /opt/arm-none-eabi and flatten
    mkdir -p "${TOOLCHAIN_DIR}"; \
    # find the extracted folder (matches xpack-arm-none-eabi-gcc-*)
    extracted="$(find . -maxdepth 1 -type d -name 'xpack-arm-none-eabi-gcc-*' | head -n1)"; \
    mv "$extracted"/* "${TOOLCHAIN_DIR}/"; \
    # optional: trim size a bit (docs/examples)
    rm -rf "${TOOLCHAIN_DIR}/share/doc" "${TOOLCHAIN_DIR}/share/info" \
           "${TOOLCHAIN_DIR}/share/man" "${TOOLCHAIN_DIR}/libexec/gcc/arm-none-eabi/"*/install-tools; \
    cd / && rm -rf /tmp/xpack

WORKDIR /work

# Sanity checks (similar style to sdcc-z80)
RUN set -e; \
    echo "=== ARM toolchain ==="; \
    arm-none-eabi-gcc --version | head -n1; \
    echo "=== GDB ==="; \
    arm-none-eabi-gdb --version | head -n1; \
    echo "=== OpenOCD ==="; \
    openocd --version | head -n1; \
    echo "Image ready."
