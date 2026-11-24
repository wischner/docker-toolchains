# Haiku OS build tools (cross-compilation toolchain) on Ubuntu
FROM ubuntu:22.04

ARG IMG_VERSION=1.3.0
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
        --build-cross-tools x86_64 -j"$(nproc)" \
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

# Match Haiku's upstream Docker flow by routing the sysroot's /boot/system to
# a real package root before building the host-side package tool.
RUN mkdir -p "${HAIKU_SYSROOT}/boot" /system \
 && if [ -e "${HAIKU_SYSROOT}/boot/system" ] && [ ! -L "${HAIKU_SYSROOT}/boot/system" ]; then \
      rm -rf "${HAIKU_SYSROOT}/boot/system"; \
    fi \
 && if [ ! -e "${HAIKU_SYSROOT}/boot/system" ]; then \
      ln -s /system "${HAIKU_SYSROOT}/boot/system"; \
    fi

# Build Haiku 'package' tool to extract HPKG files.
RUN echo "Building host package tool..." \
 && cd ${HAIKU_TOOLCHAIN_PATH}/haiku \
 && RPATTERN_SOURCE=src/kits/storage/sniffer/RPattern.cpp \
 && if ! grep -q '^#include <cstddef>$' "$RPATTERN_SOURCE"; then \
      sed -i '/#include "Data.h"/i#include <cstddef>' "$RPATTERN_SOURCE"; \
    fi \
 && JAM_JOBS="$(nproc)" \
 && if [ "$JAM_JOBS" -gt 8 ]; then JAM_JOBS=8; fi \
 && echo "Running jam with ${JAM_JOBS} jobs" \
 && jam -j"${JAM_JOBS}" -sHAIKU_OUTPUT_DIR=${HAIKU_TOOLCHAIN_PATH}/build "<build>package" \
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
 && (cd "${SYS_SYSTEM}" && haiku-package extract "$HAIKU_HPKG") \
 && (cd "${SYS_SYSTEM}" && haiku-package extract "$HAIKU_DEVEL_HPKG") \
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
 && echo "Package metadata:" \
 && cat /opt/haiku-buildtools/haiku-package-info.env \
 && echo "Checking some expected runtime bits in sysroot..." \
 && (find "${HAIKU_SYSROOT}/boot/system" -maxdepth 4 -name 'libroot.so' | head -n1 || true) \
 && (find "${HAIKU_SYSROOT}/boot/system" -maxdepth 6 -name 'crt*.o' | head -n1 || true) \
 && echo "Testing compile + link:" \
 && echo 'int main(void){return 0;}' > /tmp/test.c \
 && x86_64-unknown-haiku-gcc /tmp/test.c -o /tmp/test \
 && file /tmp/test \
 && rm -f /tmp/test.c /tmp/test \
 && echo "OK: toolchain can link Haiku binaries."

COPY haiku-x86_64.cmake /opt/toolchains/haiku-x86_64.cmake


# Pinned Native release SDK: public headers, libraries, CMake package and notices.
ARG NATIVE_VERSION=v1.1.0
ARG NATIVE_SHA256=56cffbdc4e52ae4460d1c76e762577aa1f177242c905373f8cc826eba0527b2e
ENV NATIVE_SDK=/opt/native/haiku-x86_64
ADD --checksum=sha256:${NATIVE_SHA256} https://github.com/wischner/native/releases/download/${NATIVE_VERSION}/native-${NATIVE_VERSION}-haiku-x86_64-sdk.tar.gz /tmp/native-sdk.tar.gz
RUN set -eux; \
    install -d "${NATIVE_SDK}"; \
    tar -xzf /tmp/native-sdk.tar.gz -C "${NATIVE_SDK}" --strip-components=1; \
    rm /tmp/native-sdk.tar.gz; \
    test -s "${NATIVE_SDK}/include/native.h"; \
    test -s "${NATIVE_SDK}/lib/libnative.a"; \
    test -s "${NATIVE_SDK}/lib/cmake/Native/NativeConfig.cmake"; \
    test -s "${NATIVE_SDK}/manifest.json"; \
    printf '%s\n' "${NATIVE_VERSION}" > "${NATIVE_SDK}/.version"; \
    printf '%s\n' "${NATIVE_SHA256}" > "${NATIVE_SDK}/.sha256"

# Compile and link a consumer using only the installed SDK's public interface.
RUN set -eux; \
    install -d /tmp/native-consumer; \
    printf '%s\n' \
      '#include <native.h>' \
      'int program(int, char **) {' \
      '  native::app_wnd window("Native SDK check");' \
      '  return 0;' \
      '}' > /tmp/native-consumer/main.cpp; \
    printf '%s\n' \
      'cmake_minimum_required(VERSION 3.20)' \
      'project(native_consumer LANGUAGES CXX)' \
      'find_package(Native CONFIG REQUIRED)' \
      'add_executable(native_consumer main.cpp)' \
      'target_link_libraries(native_consumer PRIVATE Native::Native)' \
      > /tmp/native-consumer/CMakeLists.txt; \
    cmake -S /tmp/native-consumer -B /tmp/native-consumer/build \
      -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/opt/toolchains/haiku-x86_64.cmake \
      -DNative_DIR="${NATIVE_SDK}/lib/cmake/Native"; \
    cmake --build /tmp/native-consumer/build; \
    file /tmp/native-consumer/build/native_consumer; \
    rm -rf /tmp/native-consumer

LABEL org.opencontainers.image.native.version="${NATIVE_VERSION}" \
      org.opencontainers.image.native.sdk="haiku-x86_64" \
      org.opencontainers.image.native.sha256="${NATIVE_SHA256}"
