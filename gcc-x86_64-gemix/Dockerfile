# GCC x86_64 GEMix development toolchain (Ubuntu 22.04)
ARG BASE_IMAGE=wischner/gcc-x86_64-linux-x11:1.0.0
FROM ${BASE_IMAGE}

ARG IMG_VERSION=1.0.0

LABEL org.opencontainers.image.title="gcc-x86_64-gemix" \
      org.opencontainers.image.description="GCC x86_64 GEMix (DRI GEM on Linux) development toolchain layered on the Linux X11 base image." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="MIT; see bundled GEMix headers for upstream notices" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive

COPY sdk/ /opt/gemix-sdk/

RUN set -eux; \
    install -d /usr/local/include /usr/local/lib/pkgconfig; \
    cp -a /opt/gemix-sdk/include/. /usr/local/include/; \
    install -m 0644 /opt/gemix-sdk/lib/libaes.so /usr/local/lib/libaes.so; \
    install -m 0644 /opt/gemix-sdk/lib/libvdi.so /usr/local/lib/libvdi.so; \
    install -m 0644 /opt/gemix-sdk/lib/libplatform_linux.so /usr/local/lib/libplatform_linux.so; \
    install -m 0644 /opt/gemix-sdk/lib/librasta.so /usr/local/lib/librasta.so; \
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
      'Libs: -L${libdir} -Wl,-rpath,${libdir} -laes -lasan -lubsan' \
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
      'Libs: -L${libdir} -Wl,-rpath,${libdir} -lvdi -lasan -lubsan' \
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
      'Libs: -L${libdir} -Wl,-rpath,${libdir} -lrasta -lasan -lubsan' \
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
      'Libs: -L${libdir} -Wl,-rpath,${libdir} -lplatform_linux -lasan -lubsan' \
      > /usr/local/lib/pkgconfig/gemix-platform-linux.pc; \
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
      > /usr/local/lib/pkgconfig/gemix.pc; \
    ldconfig

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
    echo "=== GEMix headers ==="; \
    test -f /usr/local/include/gem.h; \
    test -f /usr/local/include/gem/gem.h; \
    test -f /usr/local/include/platform/os.h; \
    echo "=== GEMix libraries ==="; \
    test -f /usr/local/lib/libaes.so; \
    test -f /usr/local/lib/libvdi.so; \
    test -f /usr/local/lib/libplatform_linux.so; \
    test -f /usr/local/lib/librasta.so; \
    echo "--- Compile tests ---"; \
    printf '#include <gem.h>\n#include <platform/os.h>\n#include <platform/raster.h>\nint main(void){\n  void *p1=(void *)appl_init;\n  void *p2=(void *)v_opnvwk;\n  void *p3=(void *)gem_raster_surface;\n  void *p4=(void *)gem_os_ticks_ms;\n  return (p1 && p2 && p3 && p4) ? 0 : 1;\n}\n' > /tmp/test-gemix.c; \
    gcc -o /tmp/test-gemix /tmp/test-gemix.c $(pkg-config --cflags --libs gemix gemix-platform-linux); \
    rm -f /tmp/test-gemix /tmp/test-gemix.c; \
    echo "All checks passed."
