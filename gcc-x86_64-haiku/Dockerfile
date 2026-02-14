# Haiku OS build tools (cross-compilation toolchain) on Ubuntu
FROM ubuntu:22.04

ARG IMG_VERSION=1.0.0
ARG HAIKU_COMMIT=r1beta5

LABEL org.opencontainers.image.title="gcc-x86_64-haiku" \
      org.opencontainers.image.description="Haiku OS cross-compilation toolchain: GCC cross-compiler with Haiku headers and Jam build system for building Haiku applications." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="MIT and others; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV HAIKU_TOOLCHAIN_PATH=/opt/haiku-buildtools
ENV DEBIAN_FRONTEND=noninteractive

# Make failures visible (trace commands + fail pipelines properly)
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# Install build dependencies (+ common packaging tools)
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    python3 \
    perl \
    bash \
    wget \
    curl \
    ca-certificates \
    autoconf \
    automake \
    libtool \
    bison \
    flex \
    gawk \
    nasm \
    texinfo \
    libncurses-dev \
    zlib1g-dev \
    cmake \
    make \
    patch \
    sed \
    grep \
    coreutils \
    file \
    rsync \
    pkg-config \
    zip \
    unzip \
    xz-utils \
    zstd \
    && rm -rf /var/lib/apt/lists/*

# Clone Haiku buildtools and source (full history needed for git describe)
# Do NOT use --depth=1 as it breaks Haiku's revision detection even after unshallow
RUN git clone --branch ${HAIKU_COMMIT} \
        https://github.com/haiku/buildtools.git ${HAIKU_TOOLCHAIN_PATH}/buildtools \
 && git clone --branch ${HAIKU_COMMIT} \
        https://github.com/haiku/haiku.git ${HAIKU_TOOLCHAIN_PATH}/haiku \
 && echo "Haiku repositories cloned successfully"

# Verify git describe works (critical for HAIKU_REVISION detection)
RUN cd ${HAIKU_TOOLCHAIN_PATH}/haiku \
 && echo "=== Git revision detection test ===" \
 && echo "Git describe:" \
 && git describe --tags --always \
 && echo "Git log (last commit):" \
 && git log -1 --oneline \
 && echo "===================================="

# Build cross-compilation toolchain for x86_64
# IMPORTANT: configure via local symlinks to avoid "../" in packaging paths
RUN mkdir -p ${HAIKU_TOOLCHAIN_PATH}/build \
 && cd ${HAIKU_TOOLCHAIN_PATH}/build \
 && ln -snf ${HAIKU_TOOLCHAIN_PATH}/haiku haiku \
 && ln -snf ${HAIKU_TOOLCHAIN_PATH}/buildtools buildtools \
 && ./haiku/configure \
        --cross-tools-source ./buildtools \
        --build-cross-tools x86_64 \
 && echo "Cross-tools configured/built successfully"

# Cross tools binaries
ENV PATH="${HAIKU_TOOLCHAIN_PATH}/build/cross-tools-x86_64/bin:${PATH}"

# Build Jam (Haiku's build system)
RUN cd ${HAIKU_TOOLCHAIN_PATH}/buildtools/jam \
 && make \
 && install -m0755 bin.*/jam /usr/local/bin/jam \
 && echo "Jam installed successfully"

# Source + sysroot (IMPORTANT: sysroot is cross-tools-x86_64/sysroot)
ENV HAIKU_SOURCE=${HAIKU_TOOLCHAIN_PATH}/haiku
ENV HAIKU_SYSROOT=${HAIKU_TOOLCHAIN_PATH}/build/cross-tools-x86_64/sysroot
ENV HAIKU_REVISION=hrev57991

# Build Haiku 'package' tool to extract HPKG files
# We need a minimal Haiku build configuration to build the package tool
RUN cd ${HAIKU_TOOLCHAIN_PATH}/build \
 \
 && echo "Configuring Haiku build for package tool..." \
 && ./haiku/configure \
        --cross-tools-source ./buildtools \
        --cross-tools-prefix ${HAIKU_TOOLCHAIN_PATH}/build/cross-tools-x86_64 \
 \
 && echo "Building host package tool..." \
 && jam -q -j"$(nproc)" "<build>package" \
 \
 && echo "Locating host 'package' tool..." \
 && PACKAGE_TOOL="$(find "${HAIKU_TOOLCHAIN_PATH}/build/objects" -type f -path '*/tools/package/package' -executable 2>/dev/null | head -n1)" \
 && test -n "$PACKAGE_TOOL" \
 && echo "Found package tool: $PACKAGE_TOOL" \
 && install -m0755 "$PACKAGE_TOOL" /usr/local/bin/haiku-package \
 \
 && echo "Setting LD_LIBRARY_PATH for host package tool..." \
 && HOST_LINUX_LIB_DIR="$(find "${HAIKU_TOOLCHAIN_PATH}/build/objects" -type d -path '*/objects/linux/*/*/lib' 2>/dev/null | head -n1 || true)" \
 && if [ -n "$HOST_LINUX_LIB_DIR" ]; then \
        echo "export LD_LIBRARY_PATH=\"$HOST_LINUX_LIB_DIR\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}\"" >> /etc/profile.d/haiku-package.sh; \
        chmod +x /etc/profile.d/haiku-package.sh; \
    fi

# Copy Haiku runtime packages from local folder (user-provided)
# Place haiku-*.hpkg and haiku_devel-*.hpkg in packages/ folder before building
COPY packages/*.hpkg /tmp/hpkgs/

# Extract HPKGs into sysroot overlay
RUN . /etc/profile.d/haiku-package.sh 2>/dev/null || true \
 && echo "Extracting Haiku runtime packages into sysroot..." \
 && ls -lh /tmp/hpkgs/ \
 && SYS_SYSTEM="${HAIKU_SYSROOT}/boot/system" \
 && mkdir -p "${SYS_SYSTEM}" \
 && HAIKU_HPKG="$(ls -1 /tmp/hpkgs/haiku-*.hpkg 2>/dev/null | grep -v devel | head -n1)" \
 && HAIKU_DEVEL_HPKG="$(ls -1 /tmp/hpkgs/haiku*_devel-*.hpkg 2>/dev/null | head -n1)" \
 && test -n "$HAIKU_HPKG" && echo "Base package: $HAIKU_HPKG" \
 && test -n "$HAIKU_DEVEL_HPKG" && echo "Devel package: $HAIKU_DEVEL_HPKG" \
 && haiku-package extract -C "${SYS_SYSTEM}" "$HAIKU_HPKG" \
 && haiku-package extract -C "${SYS_SYSTEM}" "$HAIKU_DEVEL_HPKG" \
 && rm -rf /tmp/hpkgs \
 && echo "Sysroot overlay ready at: ${SYS_SYSTEM}"

# Clean up git metadata (optional size reduction)
RUN rm -rf ${HAIKU_TOOLCHAIN_PATH}/haiku/.git \
 && rm -rf ${HAIKU_TOOLCHAIN_PATH}/buildtools/.git

WORKDIR /work

# Sanity checks and test compile+link
RUN echo "=== Haiku Cross-Compilation Toolchain (link-capable) ===" \
 && echo "Cross-compiler:" \
 && x86_64-unknown-haiku-gcc --version | head -n1 \
 && echo "Jam:" \
 && jam -v \
 && echo "Sysroot (gcc):" \
 && x86_64-unknown-haiku-gcc -print-sysroot \
 && echo "Sysroot (env): ${HAIKU_SYSROOT}" \
 && echo "Checking some expected runtime bits in sysroot..." \
 && (find "${HAIKU_SYSROOT}/boot/system" -maxdepth 4 -name 'libroot.so' | head -n1 || true) \
 && (find "${HAIKU_SYSROOT}/boot/system" -maxdepth 6 -name 'crt*.o' | head -n1 || true) \
 && echo "Testing compile + link:" \
 && echo 'int main(void){return 0;}' > /tmp/test.c \
 && x86_64-unknown-haiku-gcc /tmp/test.c -o /tmp/test \
 && file /tmp/test \
 && rm -f /tmp/test.c /tmp/test \
 && echo "OK: toolchain can link Haiku binaries."
