# wischner/gcc-arm-none-eabi-rpi-pico
# Extends the Ubuntu-based arm-none-eabi image with Pico/Pico W conveniences.

ARG BASE_IMAGE=wischner/gcc-arm-none-eabi:1.1.0
FROM ${BASE_IMAGE}

ARG IMG_VERSION=1.1.0
ARG UID=1000
ARG GID=1000

# Pin SDK tag required by picotool (>= 2.1.0)
ARG PICO_SDK_REF=2.1.0
ARG PICO_EXTRAS_REF=2.1.0

LABEL org.opencontainers.image.title="gcc-arm-none-eabi-rpi-pico" \
      org.opencontainers.image.description="Raspberry Pi Pico and Pico W toolchain on Ubuntu with Pico SDK, pioasm, picotool, Python helpers, and ccache." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

# Speed-ups for local builds that opt-in to ccache
ENV CCACHE_DIR=/work/.ccache \
    CMAKE_C_COMPILER_LAUNCHER=ccache \
    CMAKE_CXX_COMPILER_LAUNCHER=ccache \
    GIT_TERMINAL_PROMPT=0 \
    PICO_TOOLCHAIN_PATH=/usr

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
      ccache \
      git-lfs \
      autoconf \
      automake \
      libtool \
      libftdi1 \
      libftdi1-dev \
      libudev-dev \
      && rm -rf /var/lib/apt/lists/*

# --- Fetch Pico SDK (STRICT) + extras (best-effort) ---
RUN set -e; \
    clone_ref_or_fail() { \
      repo="$1"; ref="$2"; dest="$3"; \
      if git ls-remote --tags --heads "$repo" "$ref" | grep -q .; then \
        echo "Cloning $repo at '$ref' -> $dest"; \
        git clone --depth=1 --branch "$ref" "$repo" "$dest"; \
      else \
        echo "ERROR: ref '$ref' not found in $repo" >&2; exit 2; \
      fi; \
    }; \
    clone_ref_or_fail https://github.com/raspberrypi/pico-sdk.git "$PICO_SDK_REF" /opt/pico-sdk; \
    git -C /opt/pico-sdk submodule update --init --recursive --depth=1; \
    if git ls-remote --tags --heads https://github.com/raspberrypi/pico-extras.git "$PICO_EXTRAS_REF" | grep -q .; then \
      git clone --depth=1 --branch "$PICO_EXTRAS_REF" https://github.com/raspberrypi/pico-extras.git /opt/pico-extras; \
    else \
      echo "WARN: pico-extras ref '$PICO_EXTRAS_REF' not found, cloning default branch"; \
      git clone --depth=1 https://github.com/raspberrypi/pico-extras.git /opt/pico-extras; \
    fi

# Default SDK paths (override at runtime if needed)
ENV PICO_SDK_PATH=/opt/pico-sdk \
    PICO_EXTRAS_PATH=/opt/pico-extras

# Build and install pioasm (from SDK)
RUN set -e; \
    cmake -S /opt/pico-sdk/tools/pioasm -B /tmp/pioasm -DCMAKE_BUILD_TYPE=Release; \
    cmake --build /tmp/pioasm -j; \
    install -m0755 /tmp/pioasm/pioasm /usr/local/bin/pioasm; \
    rm -rf /tmp/pioasm

# Build and install picotool (requires SDK >= 2.1.0)
RUN set -e; \
    git clone --depth=1 https://github.com/raspberrypi/picotool.git /tmp/picotool; \
    cmake -S /tmp/picotool -B /tmp/picotool/build \
          -DCMAKE_BUILD_TYPE=Release \
          -DPICO_SDK_PATH=/opt/pico-sdk \
          -DPICOTOOL_BUILD_EXAMPLES=OFF \
          -DPICOTOOL_BUILD_TESTS=OFF; \
    cmake --build /tmp/picotool/build -j; \
    install -m0755 /tmp/picotool/build/picotool /usr/local/bin/picotool; \
    rm -rf /tmp/picotool

# Non-root user
RUN groupadd -g ${GID} builder && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash builder && \
    mkdir -p /work && chown -R builder:builder /work

USER builder
WORKDIR /work

# Sanity check
RUN set -e; \
    echo "=== ARM toolchain ==="; arm-none-eabi-gcc --version | head -n1; \
    echo "=== C++ toolchain ==="; arm-none-eabi-g++ --version | head -n1; \
    echo "=== OpenOCD ==="; openocd --version | head -n1; \
    echo "=== pioasm ===";     pioasm --help 2>/dev/null | head -n1 || true; \
    echo "=== picotool ===";   picotool -V || true; \
    echo "Pico layer ready."
