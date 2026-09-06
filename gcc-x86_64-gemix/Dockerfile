# GCC x86_64 GEMix development toolchain (Ubuntu 22.04)
ARG BASE_IMAGE=wischner/gcc-x86_64-linux-x11:1.2.0
FROM ${BASE_IMAGE}

ARG IMG_VERSION=1.2.0
ARG GEM_REF=v1.0.0
ARG GEM_COMMIT=0df463d9ff4b4cbbdd0612ce700c9e11e5e33661

LABEL org.opencontainers.image.title="gcc-x86_64-gemix" \
      org.opencontainers.image.description="GCC x86_64 GEMix (DRI GEM on Linux) development toolchain layered on the Linux X11 base image." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="MIT; see bundled GEM headers for upstream notices" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive \
    GEM_RESOURCE_DIR=/opt/gemix/share/gem

# Build the GEM SDK from its pinned release tag inside the image.
#
# The upstream tree also stages a prebuilt SDK under bin/sdk, but those
# binaries are linked against the build host's glibc (2.38) and, in debug
# configurations, against libasan.so.8. This base is Ubuntu 22.04 with glibc
# 2.35 and libasan.so.6, so the SDK is compiled here instead of copied in.
# The release configuration links no sanitizer runtime.
#
# The clone is pinned by tag and verified by commit so the layer is
# reproducible rather than following a moving branch.
RUN set -eux; \
    git clone --depth 1 --branch "${GEM_REF}" \
      https://github.com/triglav-os/gem.git /tmp/gem-source; \
    test "$(git -C /tmp/gem-source rev-parse HEAD)" = "${GEM_COMMIT}"; \
    cmake -S /tmp/gem-source -B /tmp/gem-source/build \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING=OFF \
      -DGEM_PLATFORM=rasta; \
    cmake --build /tmp/gem-source/build --target gem_sdk gemd --parallel "$(nproc)"; \
    install -d /opt/gemix /opt/gemix/bin /opt/gemix/share/metadata; \
    cp -a /tmp/gem-source/bin/sdk/. /opt/gemix/; \
    install -m 0755 /tmp/gem-source/bin/core/gemd /opt/gemix/bin/gemd; \
    cp -a /opt/gemix/include/. /usr/local/include/; \
    cp -a /opt/gemix/lib/. /usr/local/lib/; \
    git -C /tmp/gem-source rev-parse HEAD > /opt/gemix/share/metadata/gem.version; \
    printf '%s\n' 'https://github.com/triglav-os/gem' \
      > /opt/gemix/share/metadata/gem.source; \
    printf '%s\n' "${GEM_REF}" > /opt/gemix/share/metadata/gem.ref; \
    rm -rf /tmp/gem-source; \
    ldconfig

# The SDK ships libraries and headers but no pkg-config metadata, so the
# module files are generated here. The release libraries need no sanitizer
# runtime, so consumers are not forced to link one.
RUN set -eux; \
    install -d /usr/local/lib/pkgconfig; \
    printf '%s\n' \
      'prefix=/usr/local' \
      'exec_prefix=${prefix}' \
      'libdir=${exec_prefix}/lib' \
      'includedir=${prefix}/include' \
      '' \
      'Name: GEMix AES' \
      'Description: GEMix AES client library' \
      'Version: 1.0.0' \
      'Cflags: -I${includedir}' \
      'Libs: -L${libdir} -Wl,-rpath,${libdir} -laes' \
      'Requires: gemix-vdi' \
      > /usr/local/lib/pkgconfig/gemix-aes.pc; \
    printf '%s\n' \
      'prefix=/usr/local' \
      'exec_prefix=${prefix}' \
      'libdir=${exec_prefix}/lib' \
      'includedir=${prefix}/include' \
      '' \
      'Name: GEMix VDI' \
      'Description: GEMix VDI graphics library' \
      'Version: 1.0.0' \
      'Cflags: -I${includedir}' \
      'Libs: -L${libdir} -Wl,-rpath,${libdir} -lvdi' \
      'Requires: gemix-rasta' \
      > /usr/local/lib/pkgconfig/gemix-vdi.pc; \
    printf '%s\n' \
      'prefix=/usr/local' \
      'exec_prefix=${prefix}' \
      'libdir=${exec_prefix}/lib' \
      'includedir=${prefix}/include' \
      '' \
      'Name: GEMix Rasta' \
      'Description: GEMix raster backend library' \
      'Version: 1.0.0' \
      'Cflags: -I${includedir}' \
      'Libs: -L${libdir} -Wl,-rpath,${libdir} -lrasta' \
      > /usr/local/lib/pkgconfig/gemix-rasta.pc; \
    printf '%s\n' \
      'prefix=/usr/local' \
      'exec_prefix=${prefix}' \
      'libdir=${exec_prefix}/lib' \
      'includedir=${prefix}/include' \
      '' \
      'Name: GEMix Platform Linux' \
      'Description: GEMix Linux platform abstraction library' \
      'Version: 1.0.0' \
      'Cflags: -I${includedir}' \
      'Libs: -L${libdir} -Wl,-rpath,${libdir} -lplatform_linux' \
      > /usr/local/lib/pkgconfig/gemix-platform-linux.pc; \
    printf '%s\n' \
      'prefix=/usr/local' \
      'exec_prefix=${prefix}' \
      'libdir=${exec_prefix}/lib' \
      'includedir=${prefix}/include' \
      '' \
      'Name: GEMix GEM' \
      'Description: GEMix combined GEM client library' \
      'Version: 1.0.0' \
      'Cflags: -I${includedir}' \
      'Libs: -L${libdir} -Wl,-rpath,${libdir} -lgem' \
      'Requires: gemix-platform-linux' \
      > /usr/local/lib/pkgconfig/gemix-gem.pc; \
    printf '%s\n' \
      'prefix=/usr/local' \
      'exec_prefix=${prefix}' \
      'libdir=${exec_prefix}/lib' \
      'includedir=${prefix}/include' \
      '' \
      'Name: GEMix' \
      'Description: GEMix umbrella development package for GEM, AES, VDI, and raster APIs' \
      'Version: 1.0.0' \
      'Cflags: -I${includedir}' \
      'Libs: -L${libdir} -Wl,-rpath,${libdir}' \
      'Requires: gemix-aes' \
      > /usr/local/lib/pkgconfig/gemix.pc

WORKDIR /work

# Sanity checks
RUN set -eux; \
    echo "=== Compiler ==="; gcc --version; g++ --version; \
    echo "=== CMake ==="; cmake --version; \
    echo "=== pkg-config ==="; pkg-config --version; \
    echo "=== Base X11 ==="; pkg-config --modversion x11; \
    echo "=== GEMix pkg-config ==="; \
    pkg-config --modversion gemix; \
    pkg-config --modversion gemix-aes; \
    pkg-config --modversion gemix-vdi; \
    pkg-config --modversion gemix-rasta; \
    pkg-config --modversion gemix-platform-linux; \
    pkg-config --modversion gemix-gem; \
    echo "=== GEMix headers ==="; \
    test -f /usr/local/include/gem.h; \
    test -f /usr/local/include/gem/gem.h; \
    test -f /usr/local/include/gem/aes.h; \
    test -f /usr/local/include/gem/vdi.h; \
    test -f /usr/local/include/gem/gemd.h; \
    test -f /usr/local/include/platform/os.h; \
    echo "=== GEMix libraries ==="; \
    test -f /usr/local/lib/libaes.so; \
    test -f /usr/local/lib/libvdi.so; \
    test -f /usr/local/lib/libplatform_linux.so; \
    test -f /usr/local/lib/librasta.so; \
    test -f /usr/local/lib/libgem.so; \
    echo "=== No sanitizer runtime is required ==="; \
    ! ldd /usr/local/lib/libgem.so | grep -q 'libasan\|libubsan'; \
    echo "=== GEMix tools ==="; \
    test -x /opt/gemix/bin/gemd; \
    test -x /opt/gemix/bin/resgen; \
    echo "=== GEMix runtime resources ==="; \
    test -f "${GEM_RESOURCE_DIR}/alert_icons.rsc"; \
    test -f "${GEM_RESOURCE_DIR}/cursors.rsc"; \
    test -f "${GEM_RESOURCE_DIR}/fonts/8x16_z1.fnt"; \
    test -f "${GEM_RESOURCE_DIR}/fonts/AtariSTHigh.fnt"; \
    echo "=== Recorded revision ==="; \
    test -s /opt/gemix/share/metadata/gem.version; \
    echo "--- Compile tests ---"; \
    printf '#include <gem.h>\n#include <platform/os.h>\nint main(void){\n  void *p1=(void *)appl_init;\n  void *p2=(void *)v_opnvwk;\n  void *p3=(void *)gem_os_ticks_ms;\n  void *p4=(void *)gem_os_init;\n  return (p1 && p2 && p3 && p4) ? 0 : 1;\n}\n' > /tmp/test-gemix.c; \
    gcc -o /tmp/test-gemix /tmp/test-gemix.c $(pkg-config --cflags --libs gemix gemix-platform-linux); \
    rm -f /tmp/test-gemix /tmp/test-gemix.c; \
    echo "All checks passed."
