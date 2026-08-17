# Complete m68k-amigaos cross-development toolchain.
# This is intentionally independent of gcc-m68k: the target ABI, patched GCC,
# system headers, runtimes, and object format are AmigaOS-specific.
FROM ubuntu:24.04 AS builder

ARG AMIGA_GCC_REPOSITORY=https://github.com/AmigaPorts/m68k-amigaos-gcc.git
ARG AMIGA_GCC_REVISION=249d18305c6b76d9afb3bd0e7cfbe8f70a993a27
ARG AMIGA_GCC_SOURCE_DATE=2026-08-17T23:59:59Z
ARG AMIGA_GCC_BRANCH=amiga16.1
ARG AMIGA_GCC_GCC_REVISION=e508b2b93afb838977f1055f3bb65e143b52fbb2
ARG AMIGA_BINUTILS_BRANCH=amiga
ARG AMIGA_BINUTILS_REVISION=e9ab8a4a62fc6fc6b486ff77040cafe00229c847
ARG INSTALL_ALL_SDKS=1

ENV DEBIAN_FRONTEND=noninteractive \
    PREFIX=/opt/amiga \
    TARGET=m68k-amigaos \
    PATH="/opt/amiga/bin:${PATH}"

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    bison \
    build-essential \
    ca-certificates \
    curl \
    file \
    flex \
    gettext \
    git \
    gperf \
    lhasa \
    libexpat1-dev \
    libgmp-dev \
    libmpc-dev \
    libmpfr-dev \
    libncurses-dev \
    libpod-simple-perl \
    libreadline-dev \
    libtool \
    libzstd-dev \
    patch \
    perl \
    python3 \
    python3-dev \
    rsync \
    texinfo \
    wget \
    xutils-dev \
    xz-utils \
    zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/amiga-gcc

# Pin the orchestration repository, select the current stable GCC generation,
# then pin all fetched component repositories to the source date. Pin GCC
# itself to an exact commit as an additional guard against selecting the wrong
# compiler.
RUN git clone "${AMIGA_GCC_REPOSITORY}" . && \
    git checkout --detach "${AMIGA_GCC_REVISION}" && \
    make branch mod=gcc branch="${AMIGA_GCC_BRANCH}" && \
    make branch mod=binutils branch="${AMIGA_BINUTILS_BRANCH}" && \
    make -j"$(nproc)" update PREFIX="${PREFIX}" NDK=3.2 && \
    make v date="${AMIGA_GCC_SOURCE_DATE}" PREFIX="${PREFIX}" NDK=3.2 && \
    git checkout --detach "${AMIGA_GCC_REVISION}" && \
    git -C projects/gcc checkout --detach "${AMIGA_GCC_GCC_REVISION}" && \
    git -C projects/binutils checkout --detach "${AMIGA_BINUTILS_REVISION}" && \
    test "$(cat projects/gcc/gcc/BASE-VER)" = "16.1.1b" && \
    grep -Fq '[2.39.0]' projects/binutils/bfd/version.m4

# Filesysbox 54.10 moved its FD file from include/fd to fd. The current
# upstream SDK descriptor still names the old source path.
COPY filesysbox-sdk-54.10.patch /tmp/filesysbox-sdk-54.10.patch
RUN git apply --check /tmp/filesysbox-sdk-54.10.patch && \
    git apply /tmp/filesysbox-sdk-54.10.patch

# `all` is the upstream complete GCC suite: C/C++/Objective-C, Binutils, GDB,
# gprof, fd2sfd, fd2pragma, IRA, SFDC, vasm, NDK 3.2/1.3 headers, newlib,
# libnix, clib2, ixemul headers, libgcc/libstdc++, libdebug, and pthreads.
RUN make -j"$(nproc)" all PREFIX="${PREFIX}" NDK=3.2

# Keep optional SDK installation in its own layer so the expensive, complete
# compiler/runtime build remains cached if an external SDK changes upstream.
RUN if [ "${INSTALL_ALL_SDKS}" = 1 ]; then \
      make -j"$(nproc)" all-sdk PREFIX="${PREFIX}" NDK=3.2; \
    fi

RUN mkdir -p /opt/amiga-source-metadata && \
    git rev-parse HEAD > /opt/amiga-source-metadata/m68k-amigaos-gcc.revision && \
    git -C projects/gcc rev-parse HEAD > /opt/amiga-source-metadata/gcc.revision && \
    git -C projects/binutils rev-parse HEAD > /opt/amiga-source-metadata/binutils.revision && \
    make l > /opt/amiga-source-metadata/components.revisions && \
    git diff -- sdk/filesysbox.sdk > /opt/amiga-source-metadata/local-fixes.diff && \
    cp COPYING README.md REPORT.md default-repos .repos \
      /opt/amiga-source-metadata/ && \
    find "${PREFIX}" -type f -name '*.la' -delete

# Native utilities used around the cross compiler: disk/ROM inspection,
# API-level execution, graphics conversion, and executable compression.
FROM ubuntu:24.04 AS host-tools-builder

ARG AMIGECONV_REPOSITORY=https://github.com/tditlu/amigeconv.git
ARG AMIGECONV_REVISION=af070250498a208c24ba923366a2706a0c9d8937
ARG SHRINKLER_REPOSITORY=https://github.com/askeksa/Shrinkler.git
ARG SHRINKLER_REVISION=17cff110fcded387fe90e632805258d9c8359e94
ARG AMITOOLS_VERSION=0.8.1
ARG AMITOOLS_SHA256=f622c0725c15737e7d4820ed147f930f4cfb7b80b04c786c2bc3943b799faf7e
ARG MACHINE68K_VERSION=0.3.0
ARG MACHINE68K_SHA256=40bf621b208ae402317c3bd0abb7b6ae36124a2fc416d33599f35ee337028deb
ARG LHAFILE_VERSION=0.3.1
ARG LHAFILE_SHA256=a66a091e61af569384844ed74bf76179c575e5d28bc88bf9bf5476a3397d077d
ARG SETUPTOOLS_VERSION=80.9.0
ARG SETUPTOOLS_SHA256=062d34222ad13e0cc312a4c02d73f059e86a4acbfbdea8f8f76b28c99f306922

ENV DEBIAN_FRONTEND=noninteractive \
    HOST_TOOLS=/opt/amiga-host-tools \
    PATH="/opt/amiga-host-tools/bin:/opt/amiga-host-tools/venv/bin:${PATH}"

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    cython3 \
    git \
    python3-dev \
    python3-setuptools \
    python3-setuptools-scm \
    python3-venv \
    python3-wheel && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/amiga-host-tools

RUN git clone "${AMIGECONV_REPOSITORY}" amigeconv && \
    git -C amigeconv checkout --detach "${AMIGECONV_REVISION}" && \
    test "$(git -C amigeconv rev-parse HEAD)" = "${AMIGECONV_REVISION}" && \
    make -C amigeconv -j"$(nproc)" && \
    install -Dm755 amigeconv/bin/amigeconv "${HOST_TOOLS}/bin/amigeconv" && \
    install -Dm644 amigeconv/LICENSE \
      "${HOST_TOOLS}/share/doc/amigeconv/LICENSE" && \
    install -Dm644 amigeconv/README.md \
      "${HOST_TOOLS}/share/doc/amigeconv/README.md" && \
    printf '%s\n' "${AMIGECONV_REVISION}" \
      > "${HOST_TOOLS}/share/doc/amigeconv/revision"

RUN git clone "${SHRINKLER_REPOSITORY}" Shrinkler && \
    git -C Shrinkler checkout --detach "${SHRINKLER_REVISION}" && \
    test "$(git -C Shrinkler rev-parse HEAD)" = "${SHRINKLER_REVISION}" && \
    make -C Shrinkler -j"$(nproc)" PLATFORM=native DEBUG= && \
    install -Dm755 Shrinkler/build/native/Shrinkler \
      "${HOST_TOOLS}/bin/Shrinkler" && \
    ln -s Shrinkler "${HOST_TOOLS}/bin/shrinkler" && \
    mkdir -p "${HOST_TOOLS}/share/shrinkler" && \
    cp -a Shrinkler/decrunchers "${HOST_TOOLS}/share/shrinkler/" && \
    install -Dm644 Shrinkler/LICENSE.txt \
      "${HOST_TOOLS}/share/shrinkler/LICENSE.txt" && \
    install -Dm644 Shrinkler/README.txt \
      "${HOST_TOOLS}/share/shrinkler/README.txt" && \
    printf '%s\n' "${SHRINKLER_REVISION}" \
      > "${HOST_TOOLS}/share/shrinkler/revision"

ARG PACKAGING_VERSION=25.0
ARG PACKAGING_SHA256=29572ef2b1f17581046b3a2227d5c611fb25ec70ca1ba8554b24b0e69331a484

# Install fixed source distributions without an isolated, floating build
# environment. The venv is copied intact to the matching Ubuntu runtime.
RUN mkdir -p python-dist && \
    curl -fL --retry 3 \
      "https://files.pythonhosted.org/packages/source/a/amitools/amitools-${AMITOOLS_VERSION}.tar.gz" \
      -o "python-dist/amitools-${AMITOOLS_VERSION}.tar.gz" && \
    curl -fL --retry 3 \
      "https://files.pythonhosted.org/packages/source/m/machine68k/machine68k-${MACHINE68K_VERSION}.tar.gz" \
      -o "python-dist/machine68k-${MACHINE68K_VERSION}.tar.gz" && \
    curl -fL --retry 3 \
      "https://files.pythonhosted.org/packages/source/l/lhafile/lhafile-${LHAFILE_VERSION}.tar.gz" \
      -o "python-dist/lhafile-${LHAFILE_VERSION}.tar.gz" && \
    curl -fL --retry 3 \
      "https://files.pythonhosted.org/packages/a3/dc/17031897dae0efacfea57dfd3a82fdd2a2aeb58e0ff71b77b87e44edc772/setuptools-${SETUPTOOLS_VERSION}-py3-none-any.whl" \
      -o "python-dist/setuptools-${SETUPTOOLS_VERSION}-py3-none-any.whl" && \
    curl -fL --retry 3 \
      "https://files.pythonhosted.org/packages/20/12/38679034af332785aac8774540895e234f4d07f7545804097de4b666afd8/packaging-${PACKAGING_VERSION}-py3-none-any.whl" \
      -o "python-dist/packaging-${PACKAGING_VERSION}-py3-none-any.whl" && \
    echo "${AMITOOLS_SHA256}  python-dist/amitools-${AMITOOLS_VERSION}.tar.gz" | sha256sum -c - && \
    echo "${MACHINE68K_SHA256}  python-dist/machine68k-${MACHINE68K_VERSION}.tar.gz" | sha256sum -c - && \
    echo "${LHAFILE_SHA256}  python-dist/lhafile-${LHAFILE_VERSION}.tar.gz" | sha256sum -c - && \
    echo "${SETUPTOOLS_SHA256}  python-dist/setuptools-${SETUPTOOLS_VERSION}-py3-none-any.whl" | sha256sum -c - && \
    echo "${PACKAGING_SHA256}  python-dist/packaging-${PACKAGING_VERSION}-py3-none-any.whl" | sha256sum -c - && \
    python3 -m venv --system-site-packages "${HOST_TOOLS}/venv" && \
    "${HOST_TOOLS}/venv/bin/pip" install --no-cache-dir --no-index \
      "python-dist/packaging-${PACKAGING_VERSION}-py3-none-any.whl" \
      "python-dist/setuptools-${SETUPTOOLS_VERSION}-py3-none-any.whl" && \
    "${HOST_TOOLS}/venv/bin/pip" install --no-cache-dir --no-build-isolation \
      "python-dist/machine68k-${MACHINE68K_VERSION}.tar.gz" \
      "python-dist/amitools-${AMITOOLS_VERSION}.tar.gz" \
      "python-dist/lhafile-${LHAFILE_VERSION}.tar.gz" && \
    "${HOST_TOOLS}/venv/bin/pip" check && \
    "${HOST_TOOLS}/venv/bin/pip" freeze \
      > "${HOST_TOOLS}/share/amitools-versions.txt" && \
    python3 -c 'import machine68k' && \
    xdftool -h >/dev/null

FROM ubuntu:24.04

ARG IMG_VERSION=1.1.0
ARG INSTALL_ALL_SDKS=1

LABEL org.opencontainers.image.title="gcc-m68k-amiga" \
      org.opencontainers.image.description="Complete GCC 16.1 m68k-amigaos development suite with NDK, runtimes, debugger, SDKs, disk tools, asset converters, and compression tools." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later and others; see /usr/share/doc/amiga-toolchain" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive \
    PREFIX=/opt/amiga \
    TARGET=m68k-amigaos \
    AMIGA_GCC_ROOT=/opt/amiga \
    AMIGA_TOOLCHAIN_PATH=/opt/amiga \
    AMIGA_HOST_TOOLS=/opt/amiga-host-tools \
    VIRTUAL_ENV=/opt/amiga-host-tools/venv \
    CMAKE_TOOLCHAIN_FILE=/opt/amiga/share/cmake/m68k-amigaos.cmake \
    PATH="/opt/amiga-host-tools/bin:/opt/amiga-host-tools/venv/bin:/opt/amiga/bin:${PATH}"

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# Runtime libraries for GCC/GDB plus common project build and packaging tools.
RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    bash \
    bison \
    build-essential \
    ccache \
    ca-certificates \
    cmake \
    curl \
    file \
    flex \
    gettext \
    git \
    gperf \
    imagemagick \
    jq \
    lhasa \
    libexpat1 \
    libgmp10 \
    libmpc3 \
    libmpfr6 \
    libncurses6 \
    libreadline8t64 \
    libzstd1 \
    libtool \
    make \
    meson \
    netpbm \
    ninja-build \
    patch \
    pkg-config \
    python3 \
    python3-pip \
    rsync \
    sox \
    unzip \
    wget \
    xxd \
    xz-utils \
    zip \
    zlib1g && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/amiga /opt/amiga
COPY --from=builder /opt/amiga-source-metadata /usr/share/doc/amiga-toolchain
COPY --from=host-tools-builder /opt/amiga-host-tools /opt/amiga-host-tools
COPY m68k-amigaos.cmake /opt/amiga/share/cmake/m68k-amigaos.cmake

WORKDIR /work

# Verify every core executable and prove that modern C++ headers compile and
# link into an AmigaOS executable, rather than only checking driver versions.
RUN for tool in gcc g++ cpp as ld ar ranlib nm objcopy objdump readelf size strings strip gdb gprof; do \
      command -v "${TARGET}-${tool}" >/dev/null; \
    done && \
    for tool in fd2sfd fd2pragma ira sfdc vasmm68k_mot vobjdump; do \
      command -v "${tool}" >/dev/null; \
    done && \
    for tool in amigeconv Shrinkler shrinkler fdtool geotool hunktool rdbtool \
      romtool typetool vamos vamospath vamostool xdfscan xdftool; do \
      command -v "${tool}" >/dev/null; \
    done && \
    for tool in ccache meson convert ppmtoilbm ilbmtoppm sox soxi xxd zip unzip; do \
      command -v "${tool}" >/dev/null; \
    done && \
    "${TARGET}-gcc" --version | head -n1 && \
    "${TARGET}-g++" --version | head -n1 && \
    printf '%s\n' \
      '#include <array>' \
      'consteval int answer() { return 42; }' \
      'int main() { constexpr std::array<int, 2> a{answer(), 1}; return a[0] != 42; }' \
      >/tmp/modern.cpp && \
    "${TARGET}-g++" -std=c++23 -Os /tmp/modern.cpp -o /tmp/modern-amiga && \
    file /tmp/modern-amiga | grep -qi amiga && \
    printf '%s\n' \
      'cmake_minimum_required(VERSION 3.20)' \
      'project(amiga_smoke LANGUAGES C CXX)' \
      'add_executable(amiga-smoke modern.cpp)' \
      >/tmp/CMakeLists.txt && \
    cmake -S /tmp -B /tmp/cmake-build \
      -DCMAKE_TOOLCHAIN_FILE="${CMAKE_TOOLCHAIN_FILE}" \
      -DCMAKE_BUILD_TYPE=MinSizeRel && \
    cmake --build /tmp/cmake-build -j"$(nproc)" && \
    file /tmp/cmake-build/amiga-smoke | grep -qi amiga && \
    python3 -c 'import amitools, lhafile, machine68k' && \
    printf '%s\n' 'int main(void) { return 0; }' >/tmp/vamos-smoke.c && \
    "${TARGET}-gcc" -Os -mcrt=nix20 /tmp/vamos-smoke.c \
      -o /tmp/vamos-smoke && \
    vamos -q /tmp/vamos-smoke && \
    Shrinkler -1 -p /tmp/modern-amiga /tmp/modern-amiga.shrunk && \
    file /tmp/modern-amiga.shrunk | grep -qi amiga && \
    printf 'payload' >/tmp/payload && \
    xdftool /tmp/smoke.adf create + format SMOKE + write /tmp/payload payload && \
    xdftool /tmp/smoke.adf list | grep -q payload && \
    convert -size 16x1 xc:black /tmp/smoke.png && \
    amigeconv -f bitplane -d 1 /tmp/smoke.png /tmp/smoke.raw && \
    test "$(wc -c </tmp/smoke.raw)" -eq 2 && \
    convert /tmp/smoke.png ppm:- | \
      ppmtoilbm -quiet -ecs -fixplanes 1 >/tmp/smoke.iff && \
    ilbmtoppm -quiet /tmp/smoke.iff >/tmp/roundtrip.ppm && \
    file /tmp/smoke.iff | grep -qi ilbm && \
    sox -n -r 8000 -c 1 /tmp/smoke.8svx trim 0 0.01 && \
    soxi /tmp/smoke.8svx | grep -q '8-bit Signed Integer PCM' && \
    rm -rf /tmp/cmake-build /tmp/CMakeLists.txt /tmp/modern.cpp \
      /tmp/modern-amiga /tmp/modern-amiga.shrunk /tmp/payload /tmp/smoke.adf \
      /tmp/smoke.png /tmp/smoke.raw /tmp/smoke.iff /tmp/roundtrip.ppm \
      /tmp/smoke.8svx /tmp/vamos-smoke.c /tmp/vamos-smoke && \
    echo "Optional SDK collection installed: ${INSTALL_ALL_SDKS}"
