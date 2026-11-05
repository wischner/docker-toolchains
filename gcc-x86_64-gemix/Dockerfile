# GCC x86_64 GEMix development toolchain (Ubuntu 22.04)
ARG BASE_IMAGE=wischner/gcc-x86_64-linux-x11:1.6.0
FROM ${BASE_IMAGE}

ARG IMG_VERSION=1.4.1
ARG GEM_REF=03a9c1efdc67fef89abb9c1c3c5de9d42f133ecf
ARG GEM_COMMIT=03a9c1efdc67fef89abb9c1c3c5de9d42f133ecf

LABEL org.opencontainers.image.title="gcc-x86_64-gemix" \
      org.opencontainers.image.description="GCC x86_64 GEMix toolchain with the GEM SDK, bundled GEM programs, and the Rasta viewer." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="MIT; Gemread is AGPL-3.0-or-later; see bundled GEM headers for upstream notices" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/opt/gemix/bin:${PATH}" \
    GEM_RESOURCE_DIR=/opt/gemix/share/gem \
    GEM_SAMPLE_DATA=/opt/gemix/samples/data \
    GEM_RASTA_PORT=5000

# Rasta is an SDL2 viewer. Gemscape's prebuilt CEF runtime needs the same
# host libraries the GEM SDL container adds on top of this X11 base.
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsdl2-dev \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libatspi2.0-0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libxkbcommon0 \
    libgbm1 \
    libpango-1.0-0 \
    libcairo2 \
    libcups2 \
    libasound2 \
    libxss1 \
    && rm -rf /var/lib/apt/lists/*

COPY gem-desktop /opt/gemix/bin/gem-desktop

# Build the pinned GEM revision inside the image. The upstream tree also
# stages a prebuilt SDK, but those binaries are linked against another
# host's glibc. This base is Ubuntu 22.04, so the SDK, bundled programs,
# and Rasta viewer are compiled here. Release links no sanitizer runtime.
#
# GEM_COMMIT is fetched directly so the layer does not follow a moving
# branch. Gemscape bakes its CEF resource path at compile time, so the
# extracted CEF runtime is kept at that path after the other build files
# are removed.
RUN set -eux; \
    install -d /tmp/gem-source /opt/gemix/bin /opt/gemix/share/metadata; \
    git init /tmp/gem-source; \
    git -C /tmp/gem-source remote add origin https://github.com/triglav-os/gem.git; \
    git -c protocol.version=2 -C /tmp/gem-source fetch --depth 1 origin "${GEM_COMMIT}"; \
    git -C /tmp/gem-source checkout --detach FETCH_HEAD; \
    test "$(git -C /tmp/gem-source rev-parse HEAD)" = "${GEM_COMMIT}"; \
    cmake -S /tmp/gem-source -B /opt/gemix/work \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING=OFF \
      -DGEM_PLATFORM=rasta \
      -DGEM_OUTPUT_ROOT=/opt/gemix; \
    cmake --build /opt/gemix/work --parallel "$(nproc)" --target \
      gem_sdk rasta_viewer \
      gem_runtime_desktop_icons \
      gemd desktop desktop_hosted \
      terminal \
      calc calc_gemd \
      clock clock_gemd \
      stout \
      gemread gemread_hosted \
      gemscape gemscape_hosted; \
    cp -a /tmp/gem-source/include/fat12 /opt/gemix/sdk/include/fat12; \
    cp -a /tmp/gem-source/include/msa /opt/gemix/sdk/include/msa; \
    cp -a /tmp/gem-source/include/prg /opt/gemix/sdk/include/prg; \
    musashi_lib="$(find /opt/gemix/work -name libmusashi.a -print -quit)"; \
    test -n "${musashi_lib}"; \
    cp -a "${musashi_lib}" /opt/gemix/sdk/lib/libmusashi.a; \
    cp -a /opt/gemix/sdk/include/. /usr/local/include/; \
    cp -a /opt/gemix/sdk/lib/. /usr/local/lib/; \
    ln -sfn /opt/gemix/sdk/share/gem /opt/gemix/share/gem; \
    install -d /opt/gemix/bin; \
    link_tool() { \
      test -f "$2"; \
      ln -sfn "$2" "/opt/gemix/bin/$1"; \
      ln -sfn "$2" "/usr/local/bin/$1"; \
    }; \
    link_tool gemd /opt/gemix/core/gemd; \
    link_tool desktop /opt/gemix/apps/desktop; \
    link_tool desktop_hosted /opt/gemix/apps/desktop_hosted; \
    link_tool terminal /opt/gemix/apps/terminal; \
    link_tool calc /opt/gemix/apps/calc; \
    link_tool calc_hosted /opt/gemix/apps/calc_hosted; \
    link_tool clock /opt/gemix/apps/clock; \
    link_tool clock_hosted /opt/gemix/apps/clock_hosted; \
    link_tool stout /opt/gemix/apps/stout; \
    link_tool gemread /opt/gemix/apps/gemread; \
    link_tool gemread_hosted /opt/gemix/apps/gemread_hosted; \
    link_tool gemscape /opt/gemix/apps/gemscape; \
    link_tool gemscape_hosted /opt/gemix/apps/gemscape_hosted; \
    link_tool resgen /opt/gemix/sdk/bin/resgen; \
    link_tool rasta /opt/gemix/tools/rasta; \
    chmod 0755 /opt/gemix/bin/gem-desktop; \
    ln -sfn /opt/gemix/bin/gem-desktop /usr/local/bin/gem-desktop; \
    git -C /tmp/gem-source rev-parse HEAD > /opt/gemix/share/metadata/gem.version; \
    printf '%s\n' 'https://github.com/triglav-os/gem' \
      > /opt/gemix/share/metadata/gem.source; \
    printf '%s\n' "${GEM_REF}" > /opt/gemix/share/metadata/gem.ref; \
    sed -n 's/.*GEM_RASTA_REVISION "\([0-9a-f]*\)".*/\1/p' \
      /tmp/gem-source/tools/scripts/rasta.cmake \
      > /opt/gemix/share/metadata/rasta.version; \
    test -s /opt/gemix/share/metadata/rasta.version; \
    printf '%s\n' 'https://github.com/tstih/rasta' \
      > /opt/gemix/share/metadata/rasta.source; \
    find /opt/gemix/work -mindepth 1 -maxdepth 1 ! -name deps -exec rm -rf {} +; \
    find /opt/gemix/work/deps -mindepth 1 -maxdepth 1 ! -name cef -exec rm -rf {} +; \
    find /opt/gemix/work/deps/cef -mindepth 1 -maxdepth 1 ! -name source -exec rm -rf {} +; \
    test -f /opt/gemix/work/deps/cef/source/Release/libcef.so; \
    test -d /opt/gemix/work/deps/cef/source/Resources; \
    rm -rf /tmp/gem-source; \
    ldconfig

# The SDK ships libraries and headers but no pkg-config metadata.
ARG IMG_VERSION=1.4.1
RUN set -eux; \
    install -d /usr/local/lib/pkgconfig; \
    pc() { \
      name="$1"; desc="$2"; libs="$3"; requires="${4:-}"; \
      { \
        printf '%s\n' \
          'prefix=/usr/local' \
          'exec_prefix=${prefix}' \
          'libdir=${exec_prefix}/lib' \
          'includedir=${prefix}/include' \
          '' \
          "Name: ${name}" \
          "Description: ${desc}" \
          "Version: ${IMG_VERSION}" \
          'Cflags: -I${includedir}' \
          "Libs: -L\${libdir} -Wl,-rpath,\${libdir} ${libs}"; \
        if [ -n "${requires}" ]; then \
          printf 'Requires: %s\n' "${requires}"; \
        fi; \
      } > "/usr/local/lib/pkgconfig/${name}.pc"; \
    }; \
    pc gemix-rasta 'GEMix Rasta client library' '-lrasta'; \
    pc gemix-platform-linux 'GEMix Linux platform abstraction library' '-lplatform_linux'; \
    pc gemix-musashi 'Musashi 68000 interpreter used by Stout' '-lmusashi -lm'; \
    pc gemix-fat12 'GEMix FAT12 disk image library' '-lfat12'; \
    pc gemix-msa 'GEMix MSA disk image library' '-lmsa'; \
    pc gemix-prg 'GEMix Atari PRG library' '-lprg' 'gemix-platform-linux'; \
    pc gemix-gemconf 'GEMix configuration library' '-lgemconf'; \
    pc gemix-gemctl 'GEMix control library' '-lgemctl' 'gemix-aes'; \
    pc gemix-vdi 'GEMix VDI graphics library' '-lvdi' 'gemix-rasta'; \
    pc gemix-aes 'GEMix AES client library' '-laes' 'gemix-vdi'; \
    pc gemix-gem 'GEMix combined GEM client library' '-lgem' 'gemix-platform-linux'; \
    pc gemix-stout 'GEMix Stout disk and guest support library' '-lstout' \
      'gemix-gem gemix-prg gemix-fat12 gemix-msa gemix-platform-linux gemix-musashi'; \
    pc gemix 'GEMix umbrella development package' '' 'gemix-aes'

WORKDIR /work

COPY smoke-rasta.sh /opt/gemix/libexec/smoke-rasta

# Sanity checks. A missing runtime file fails the image build.
RUN set -eux; \
    echo "=== Compiler ==="; gcc --version; g++ --version; \
    echo "=== CMake ==="; cmake --version; \
    echo "=== pkg-config ==="; pkg-config --version; \
    echo "=== Base X11 ==="; pkg-config --modversion x11; \
    echo "=== SDL2 ==="; pkg-config --modversion sdl2; \
    echo "=== GEMix pkg-config ==="; \
    for module in gemix gemix-aes gemix-vdi gemix-rasta gemix-platform-linux \
        gemix-gem gemix-gemconf gemix-gemctl gemix-fat12 gemix-msa gemix-prg \
        gemix-stout gemix-musashi; do \
      pkg-config --exists "$module"; \
      pkg-config --modversion "$module"; \
    done; \
    echo "=== GEMix headers ==="; \
    test -f /usr/local/include/gem.h; \
    test -f /usr/local/include/gem/gem.h; \
    test -f /usr/local/include/gem/aes.h; \
    test -f /usr/local/include/gem/input.h; \
    test -f /usr/local/include/gem/vdi.h; \
    test -f /usr/local/include/gem/gemd.h; \
    test -f /usr/local/include/gem/gemconf.h; \
    test -f /usr/local/include/gem/gemctl.h; \
    test -f /usr/local/include/gem/overlay.h; \
    test -f /usr/local/include/platform/os.h; \
    test -f /usr/local/include/stout/disk.h; \
    test -f /usr/local/include/fat12/fat12.h; \
    test -f /usr/local/include/msa/msa.h; \
    test -f /usr/local/include/prg/prg.h; \
    echo "=== GEMix libraries ==="; \
    for library in libaes.so libvdi.so librasta.so libplatform_linux.so \
        libgem.so libfat12.so libmsa.so libprg.so libgemconf.a libgemctl.a \
        libstout.a libmusashi.a; do \
      test -f "/usr/local/lib/${library}"; \
      test -f "/opt/gemix/sdk/lib/${library}"; \
    done; \
    echo "=== No sanitizer runtime is required ==="; \
    for binary in /usr/local/lib/libgem.so /usr/local/lib/libaes.so \
        /opt/gemix/core/gemd /opt/gemix/apps/desktop /opt/gemix/tools/rasta \
        /opt/gemix/apps/gemread /opt/gemix/apps/stout; do \
      ldd "$binary"; \
      ! ldd "$binary" | grep -q 'libasan\|libubsan\|not found'; \
    done; \
    ldd /opt/gemix/apps/gemscape; \
    ! ldd /opt/gemix/apps/gemscape | grep -q 'not found'; \
    echo "=== GEMix programs ==="; \
    for program in gemd desktop desktop_hosted terminal calc calc_hosted \
        clock clock_hosted stout gemread gemread_hosted gemscape \
        gemscape_hosted resgen rasta gem-desktop; do \
      command -v "$program"; \
      test -x "$(command -v "$program")"; \
    done; \
    echo "=== GEMix runtime resources ==="; \
    test -f "${GEM_RESOURCE_DIR}/alert_icons.rsc"; \
    test -f "${GEM_RESOURCE_DIR}/cursors.rsc"; \
    test -f "${GEM_RESOURCE_DIR}/fonts/8x16_z1.fnt"; \
    test -f "${GEM_RESOURCE_DIR}/fonts/AtariSTHigh.fnt"; \
    test -f "${GEM_SAMPLE_DATA}/desktop_icons.rsc"; \
    test -f "${GEM_SAMPLE_DATA}/clock_numbers.rsc"; \
    test -f "${GEM_SAMPLE_DATA}/gemscape_toolbar.rsc"; \
    test -f /opt/gemix/work/deps/cef/source/Release/libcef.so; \
    test -d /opt/gemix/work/deps/cef/source/Resources; \
    echo "=== Recorded revision ==="; \
    test -s /opt/gemix/share/metadata/gem.version; \
    test -s /opt/gemix/share/metadata/rasta.version; \
    echo "=== Rasta usage ==="; \
    rasta --help > /tmp/rasta-help.txt 2>&1; \
    grep -q -- '--bpp' /tmp/rasta-help.txt; \
    rm -f /tmp/rasta-help.txt; \
    echo "=== Rasta starts under Xvfb ==="; \
    chmod 0755 /opt/gemix/libexec/smoke-rasta; \
    xvfb-run -a -e /tmp/xvfb-error.log /opt/gemix/libexec/smoke-rasta \
      || { cat /tmp/xvfb-error.log /tmp/rasta-smoke.log >&2; exit 1; }; \
    echo "--- Compile tests ---"; \
    printf '%s\n' \
      '#include <gem.h>' \
      '#include <platform/os.h>' \
      '#include <gem/gemconf.h>' \
      '#include <gem/gemctl.h>' \
      '#include <fat12/fat12.h>' \
      '#include <msa/msa.h>' \
      '#include <prg/prg.h>' \
      '#include <stout/disk.h>' \
      'int main(void){' \
      '  void *p1=(void *)appl_init;' \
      '  void *p2=(void *)v_opnvwk;' \
      '  void *p3=(void *)gem_os_ticks_ms;' \
      '  void *p4=(void *)gem_os_init;' \
      '  void *p5=(void *)gemconf_init;' \
      '  void *p6=(void *)gemctl_text_edit_init;' \
      '  void *p7=(void *)fat12_image_open;' \
      '  void *p8=(void *)msa_image_init;' \
      '  void *p9=(void *)prg_image_init;' \
      '  void *p10=(void *)stout_disk_init;' \
      '  return (p1 && p2 && p3 && p4 && p5 && p6 && p7 && p8 && p9 && p10) ? 0 : 1;' \
      '}' \
      > /tmp/test-gemix.c; \
    gcc -o /tmp/test-gemix /tmp/test-gemix.c \
      $(pkg-config --cflags --libs gemix gemix-platform-linux gemix-gemconf gemix-gemctl gemix-fat12 gemix-msa gemix-prg gemix-stout); \
    rm -f /tmp/test-gemix /tmp/test-gemix.c; \
    echo "All checks passed."
