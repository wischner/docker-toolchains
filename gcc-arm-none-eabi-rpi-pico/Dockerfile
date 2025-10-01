# wischner/gcc-arm-none-eabi-rpi-pico
# Extends your base image with Pico/Pico W conveniences and ships the Pico SDK.
FROM wischner/gcc-arm-none-eabi:latest

ARG IMG_VERSION=1.0.0
ARG UID=1000
ARG GID=1000

# Pin SDK tag required by picotool (>= 2.1.0). Adjust if you want a newer tag.
ARG PICO_SDK_REF=2.1.0
# pico-extras is optional; try to pin to the same tag, but we'll fallback to default if missing.
ARG PICO_EXTRAS_REF=2.1.0

LABEL org.opencontainers.image.title="gcc-arm-none-eabi-rpi-pico" \
      org.opencontainers.image.description="Pico/Pico W tools on top of wischner/gcc-arm-none-eabi: ships Pico SDK, pioasm, picotool, Python utils, ccache." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

# Speed-ups for local builds that opt-in to ccache
ENV CCACHE_DIR=/work/.ccache \
    CMAKE_C_COMPILER_LAUNCHER=ccache \
    CMAKE_CXX_COMPILER_LAUNCHER=ccache \
    GIT_TERMINAL_PROMPT=0 \
    # Make toolchain discovery explicit for Pico SDK (Alpine-native toolchain lives in /usr)
    PICO_TOOLCHAIN_PATH=/usr

# Packages (Alpine 3.20)
RUN apk add --no-cache \
      cmake \
      python3 py3-pip py3-pyserial py3-elftools \
      build-base ccache git-lfs pkgconf \
      libusb libusb-dev hidapi hidapi-dev libftdi1 libftdi1-dev \
      autoconf automake libtool linux-headers \
      wget tar xz

# --- Fetch Pico SDK (STRICT: fail if tag doesn't exist) + extras (best-effort) ---
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
RUN addgroup -g ${GID} builder && \
    adduser -D -u ${UID} -G builder builder && \
    mkdir -p /work && chown -R builder:builder /work

USER builder
WORKDIR /work

# Sanity check
RUN set -e; \
    echo "=== ARM toolchain ==="; arm-none-eabi-gcc --version | head -n1; \
    echo "=== pioasm ===";     pioasm --help 2>/dev/null | head -n1 || true; \
    echo "=== picotool ===";   picotool -V || true; \
    echo "Pico layer ready."
