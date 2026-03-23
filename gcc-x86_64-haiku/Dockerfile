# Haiku OS build tools (cross-compilation toolchain) on Ubuntu
FROM ubuntu:22.04

ARG IMG_VERSION=1.0.0
ARG HAIKU_COMMIT=master
ARG HAIKU_PACKAGE_MIRROR=https://eu.hpkg.haiku-os.org
ARG HAIKU_PACKAGE_BRANCH=master
ARG HAIKU_PACKAGE_ARCH=x86_64
ARG HAIKU_PACKAGE_VERSION=latest
ARG HAIKU_NIGHTLY_INDEX_URL=https://download.haiku-os.org/nightly-images/x86_64/

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
    libzstd-dev \
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

# GCC 13 cross build installs only libstdc++-static.a for x86_64.
# Provide the conventional libstdc++.a name so plain `-lstdc++` links work.
RUN LIB_DIR="${HAIKU_TOOLCHAIN_PATH}/build/cross-tools-x86_64/x86_64-unknown-haiku/lib" \
 && if [ -f "${LIB_DIR}/libstdc++-static.a" ] && [ ! -e "${LIB_DIR}/libstdc++.a" ]; then \
        ln -s libstdc++-static.a "${LIB_DIR}/libstdc++.a"; \
    fi

# Build Jam (Haiku's build system)
RUN cd ${HAIKU_TOOLCHAIN_PATH}/buildtools/jam \
 && make \
 && install -m0755 bin.*/jam /usr/local/bin/jam \
 && echo "Jam installed successfully"

# Source + sysroot (IMPORTANT: sysroot is cross-tools-x86_64/sysroot)
ENV HAIKU_SOURCE=${HAIKU_TOOLCHAIN_PATH}/haiku
ENV HAIKU_SYSROOT=${HAIKU_TOOLCHAIN_PATH}/build/cross-tools-x86_64/sysroot
ENV HAIKU_REVISION=auto

# Build Haiku 'package' tool to extract HPKG files
# We need a minimal Haiku build configuration to build the package tool
RUN cd ${HAIKU_TOOLCHAIN_PATH}/build \
 \
 && echo "Configuring Haiku build for package tool..." \
 && ./haiku/configure \
        --cross-tools-source ./buildtools \
        --cross-tools-prefix ${HAIKU_TOOLCHAIN_PATH}/build/cross-tools-x86_64/bin/x86_64-unknown-haiku- \
 \
 && echo "Building host package tool..." \
 && cd ${HAIKU_TOOLCHAIN_PATH}/haiku \
 && jam -q -j"$(nproc)" -sHAIKU_OUTPUT_DIR=${HAIKU_TOOLCHAIN_PATH}/build "<build>package" \
 && cd ${HAIKU_TOOLCHAIN_PATH}/build \
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

# Optional local runtime package override.
# If HPKGs are provided in packages/, they are used. Otherwise the build fetches
# the latest package pair from the EU mirror automatically.
COPY packages/ /opt/haiku-packages/

# Resolve and extract HPKGs into sysroot overlay
RUN . /etc/profile.d/haiku-package.sh 2>/dev/null || true \
 && echo "Resolving Haiku runtime packages..." \
 && mkdir -p /tmp/hpkgs \
 && shopt -s nullglob \
 && LOCAL_BASE=(/opt/haiku-packages/haiku-*.hpkg) \
 && LOCAL_DEVEL=(/opt/haiku-packages/haiku_devel-*.hpkg) \
 && if [ ${#LOCAL_BASE[@]} -gt 0 ] && [ ${#LOCAL_DEVEL[@]} -gt 0 ]; then \
      echo "Using local HPKG files from /opt/haiku-packages"; \
      cp "${LOCAL_BASE[0]}" /tmp/hpkgs/; \
      cp "${LOCAL_DEVEL[0]}" /tmp/hpkgs/; \
    else \
      echo "Downloading HPKG files from ${HAIKU_PACKAGE_MIRROR}"; \
      PKG_VERSION="${HAIKU_PACKAGE_VERSION}"; \
      if [ "${PKG_VERSION}" = "latest" ]; then \
        HREV_FROM_NIGHTLY="$(curl -fsSL "${HAIKU_NIGHTLY_INDEX_URL}" | sed -n 's/.*haiku-master-hrev\([0-9]\+\)-x86_64-anyboot\.zip.*/\1/p' | head -n1)"; \
        VERSIONS_RAW="$(curl -fsSL "${HAIKU_PACKAGE_MIRROR}/haiku/${HAIKU_PACKAGE_BRANCH}/${HAIKU_PACKAGE_ARCH}/")"; \
        CANDIDATES="$(printf '%s' "${VERSIONS_RAW}" | tr -d '[]\" ' | tr ',' '\n' | grep -E '^r1~beta[0-9]+_hrev[0-9]+' | grep -v '_dirty' || true)"; \
        if [ -n "${HREV_FROM_NIGHTLY}" ]; then \
          PKG_VERSION="$(printf '%s\n' "${CANDIDATES}" | grep -E "_hrev${HREV_FROM_NIGHTLY}(_[0-9]+)?$" | sort -V | tail -n1 || true)"; \
        fi; \
        if [ -z "${PKG_VERSION}" ]; then \
          PKG_VERSION="$(printf '%s\n' "${CANDIDATES}" | sort -V | tail -n1)"; \
        fi; \
      fi; \
      test -n "${PKG_VERSION}"; \
      BASE_URL="${HAIKU_PACKAGE_MIRROR}/haiku/${HAIKU_PACKAGE_BRANCH}/${HAIKU_PACKAGE_ARCH}/${PKG_VERSION}/packages"; \
      BASE_PKG="haiku-${PKG_VERSION}-1-${HAIKU_PACKAGE_ARCH}.hpkg"; \
      DEVEL_PKG="haiku_devel-${PKG_VERSION}-1-${HAIKU_PACKAGE_ARCH}.hpkg"; \
      echo "Selected package version: ${PKG_VERSION}"; \
      curl -fsSL -o "/tmp/hpkgs/${BASE_PKG}" "${BASE_URL}/${BASE_PKG}"; \
      curl -fsSL -o "/tmp/hpkgs/${DEVEL_PKG}" "${BASE_URL}/${DEVEL_PKG}"; \
    fi \
 && echo "Extracting Haiku runtime packages into sysroot..." \
 && ls -lh /tmp/hpkgs/ \
 && SYS_SYSTEM="${HAIKU_SYSROOT}/boot/system" \
 && mkdir -p "${SYS_SYSTEM}" \
 && HAIKU_HPKG="$(ls -1 /tmp/hpkgs/haiku-*.hpkg 2>/dev/null | grep -v devel | head -n1)" \
 && HAIKU_DEVEL_HPKG="$(ls -1 /tmp/hpkgs/haiku_devel-*.hpkg 2>/dev/null | head -n1)" \
 && test -n "$HAIKU_HPKG" && echo "Base package: $HAIKU_HPKG" \
 && test -n "$HAIKU_DEVEL_HPKG" && echo "Devel package: $HAIKU_DEVEL_HPKG" \
 && RESOLVED_VERSION="$(basename "$HAIKU_HPKG" | sed -n 's/^haiku-\(.*\)-1-x86_64\.hpkg$/\1/p')" \
 && RESOLVED_REVISION="$(basename "$HAIKU_HPKG" | sed -n 's/.*\(hrev[0-9]\+\).*/\1/p')" \
 && test -n "${RESOLVED_VERSION}" \
 && test -n "${RESOLVED_REVISION}" \
 && printf 'HAIKU_PACKAGE_VERSION=%s\nHAIKU_REVISION=%s\n' "${RESOLVED_VERSION}" "${RESOLVED_REVISION}" > /opt/haiku-buildtools/haiku-package-info.env \
 && haiku-package extract -C "${SYS_SYSTEM}" "$HAIKU_HPKG" \
 && haiku-package extract -C "${SYS_SYSTEM}" "$HAIKU_DEVEL_HPKG" \
 && mkdir -p "${SYS_SYSTEM}/bin" \
 && install -m0755 /opt/haiku-packages/binaries/gdb "${SYS_SYSTEM}/bin/gdb" \
 && install -m0755 /opt/haiku-packages/binaries/gdbserver "${SYS_SYSTEM}/bin/gdbserver" \
 && rm -rf /tmp/hpkgs \
 && echo "Sysroot overlay ready at: ${SYS_SYSTEM}" \
 && echo "Bundled Haiku debugger binaries installed at: ${SYS_SYSTEM}/bin"

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
 && echo "Package metadata:" \
 && cat /opt/haiku-buildtools/haiku-package-info.env \
 && echo "Checking some expected runtime bits in sysroot..." \
 && (find "${HAIKU_SYSROOT}/boot/system" -maxdepth 4 -name 'libroot.so' | head -n1 || true) \
 && (find "${HAIKU_SYSROOT}/boot/system" -maxdepth 6 -name 'crt*.o' | head -n1 || true) \
 && echo "Checking bundled Haiku debugger binaries..." \
 && test -x "${HAIKU_SYSROOT}/boot/system/bin/gdb" \
 && test -x "${HAIKU_SYSROOT}/boot/system/bin/gdbserver" \
 && file "${HAIKU_SYSROOT}/boot/system/bin/gdb" \
 && file "${HAIKU_SYSROOT}/boot/system/bin/gdbserver" \
 && echo "Testing compile + link:" \
 && echo 'int main(void){return 0;}' > /tmp/test.c \
 && x86_64-unknown-haiku-gcc /tmp/test.c -o /tmp/test \
 && file /tmp/test \
 && rm -f /tmp/test.c /tmp/test \
 && echo "OK: toolchain can link Haiku binaries."
