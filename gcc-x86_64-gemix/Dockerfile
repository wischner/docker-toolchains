# GCC x86_64 GEMix development toolchain (Ubuntu 22.04)
ARG BASE_IMAGE=wischner/gcc-x86_64-linux-x11:1.6.0
FROM ${BASE_IMAGE}

ARG IMG_VERSION=1.5.0
ARG GEM_REF=v1.0.3
ARG GEM_COMMIT=d940cf31ee9e85af0264a83abd1526d4475ffb0c
ARG NATIVE_REF=v0.9.1
ARG NATIVE_COMMIT=0bddb80f30fca01067172e441b0ab48fde782ce3

LABEL org.opencontainers.image.title="gcc-x86_64-gemix" \
      org.opencontainers.image.description="GCC x86_64 GEMix toolchain with the GEM SDK, the Native C++ SDK for GEMix, bundled GEM programs, and the Rasta viewer." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="MIT; Gemread is AGPL-3.0-or-later; see bundled GEM headers and /opt/gemix/native/*/share/licenses for upstream notices" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/opt/gemix/bin:${PATH}" \
    GEM_RESOURCE_DIR=/opt/gemix/share/gem \
    GEM_SAMPLE_DATA=/opt/gemix/samples/data \
    GEM_RASTA_PORT=5000 \
    NATIVE_GEMIX_SDK=/opt/gemix/native/hosted \
    NATIVE_GEMIX_GEMD_SDK=/opt/gemix/native/gemd

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
    GEM_IN_CONTAINER=1 cmake -S /tmp/gem-source -B /opt/gemix/work \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING=OFF \
      -DGEM_PLATFORM=rasta \
      -DGEM_OUTPUT_ROOT=/opt/gemix; \
    GEM_IN_CONTAINER=1 cmake --build /opt/gemix/work --parallel "$(nproc)" --target \
      gem_sdk rasta_viewer \
      gem_runtime_desktop_icons gem_launcher_icons \
      gemd desktop desktop_hosted \
      terminal \
      calc calc_gemd \
      clock clock_gemd \
      stout \
      gemread gemread_hosted \
      gemscape gemscape_hosted \
      ted; \
    for component in fat12 msa prg stout; do \
      install -d "/opt/gemix/sdk/include/${component}"; \
      cp -a "/tmp/gem-source/include/${component}/." "/opt/gemix/sdk/include/${component}/"; \
    done; \
    for library in libprg.so libstout.a libmusashi.a; do \
      if [ ! -f "/opt/gemix/sdk/lib/${library}" ]; then \
        built="$(find /opt/gemix/lib /opt/gemix/work -name "${library}" -print -quit)"; \
        test -n "${built}"; \
        cp -a "${built}" "/opt/gemix/sdk/lib/${library}"; \
      fi; \
    done; \
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
    link_tool ted /opt/gemix/apps/ted; \
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
ARG IMG_VERSION=1.5.0
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

# Native C++ UI SDK for GEMix (https://github.com/wischner/native).
# Native's published Linux GEMix SDKs are linked against whatever GEM was
# in its CI image, so both variants are built here against the GEM above
# with Native's own release packager. The packager stages the public
# headers, libnative.a, the link dependency closure, and a relocatable
# CMake package, then links a consumer against the relocated tree.
#   hosted: AES/VDI run in-process and draw straight to Rasta.
#   gemd:   calls go through libgem to a running gemd.
# The pkg-config entries link the image's own GEM libraries (the SDK
# copies are the same files) so the system C++ runtime is used at run time.
ARG IMG_VERSION=1.5.0
ARG NATIVE_REF=v0.9.1
ARG NATIVE_COMMIT=0bddb80f30fca01067172e441b0ab48fde782ce3
RUN set -eux; \
    git init /tmp/native-source; \
    git -C /tmp/native-source remote add origin https://github.com/wischner/native.git; \
    git -c protocol.version=2 -C /tmp/native-source fetch --depth 1 origin "${NATIVE_COMMIT}"; \
    git -C /tmp/native-source checkout --detach FETCH_HEAD; \
    test "$(git -C /tmp/native-source rev-parse HEAD)" = "${NATIVE_COMMIT}"; \
    install -d /opt/gemix/native; \
    for variant in hosted gemd; do \
      case "${variant}" in \
        hosted) sdk_id=linux-gemix-x86_64; extra= ;; \
        gemd) sdk_id=linux-gemix-gemd-x86_64; extra=-DGEMIX_USE_GEMD=ON ;; \
      esac; \
      cmake -S /tmp/native-source -B "/tmp/native-source/build/${sdk_id}" \
        -DTOOLKIT=GEMIX ${extra} \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_TESTING=OFF \
        -DNATIVE_DOCKER_CONTROL_ONLY=OFF \
        -DNATIVE_BUILD_SDK=ON \
        -DNATIVE_SDK_VERSION="${NATIVE_REF}" \
        -DNATIVE_SDK_ID="${sdk_id}"; \
      cmake --build "/tmp/native-source/build/${sdk_id}" --parallel "$(nproc)"; \
      archive="/tmp/native-source/build/release/native-${NATIVE_REF}-${sdk_id}-sdk.tar.gz"; \
      test -f "${archive}"; \
      install -d "/opt/gemix/native/${variant}"; \
      tar -xzf "${archive}" -C "/opt/gemix/native/${variant}" --strip-components=1; \
      test -f "/opt/gemix/native/${variant}/lib/libnative.a"; \
      test -f "/opt/gemix/native/${variant}/lib/cmake/Native/NativeConfig.cmake"; \
    done; \
    install -d /opt/gemix/share/metadata; \
    git -C /tmp/native-source rev-parse HEAD > /opt/gemix/share/metadata/native.version; \
    printf '%s\n' "${NATIVE_REF}" > /opt/gemix/share/metadata/native.ref; \
    printf '%s\n' 'https://github.com/wischner/native' \
      > /opt/gemix/share/metadata/native.source; \
    rm -rf /tmp/native-source /tmp/build /tmp/consumer; \
    native_pc() { \
      name="$1"; desc="$2"; sdk="$3"; libs="$4"; requires="$5"; \
      printf '%s\n' \
        "prefix=${sdk}" \
        'libdir=${prefix}/lib' \
        'includedir=${prefix}/include' \
        '' \
        "Name: ${name}" \
        "Description: ${desc}" \
        "Version: ${NATIVE_REF#v}" \
        "Requires.private: ${requires}" \
        'Cflags: -std=c++20 -I${includedir}' \
        "Libs: \${libdir}/libnative.a ${libs} -ldl -lpng -lz -ljpeg" \
        > "/usr/local/lib/pkgconfig/${name}.pc"; \
    }; \
    native_pc native-gemix 'Native C++ UI library, hosted GEMix backend' \
      /opt/gemix/native/hosted \
      '-L/usr/local/lib -Wl,-rpath,/usr/local/lib -laes -lvdi -lrasta' \
      'gemix-aes'; \
    native_pc native-gemix-gemd 'Native C++ UI library, gemd client GEMix backend' \
      /opt/gemix/native/gemd \
      '-L/usr/local/lib -Wl,-rpath,/usr/local/lib -lgem -lplatform_linux' \
      'gemix-gem'

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
        gemscape_hosted ted resgen rasta gem-desktop; do \
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
    echo "=== Native SDK ==="; \
    test -s /opt/gemix/share/metadata/native.version; \
    test -f "${NATIVE_GEMIX_SDK}/include/native.h"; \
    test -f "${NATIVE_GEMIX_GEMD_SDK}/include/native.h"; \
    printf '%s\n' \
      '#include <native.h>' \
      'int program(int, char **) {' \
      '  native::app_wnd window("Native check");' \
      '  return native::app::run(window);' \
      '}' \
      > /tmp/test-native.cpp; \
    for module in native-gemix native-gemix-gemd; do \
      pkg-config --modversion "$module"; \
      g++ -o /tmp/test-native /tmp/test-native.cpp \
        $(pkg-config --cflags --libs "$module"); \
      ldd /tmp/test-native; \
      ! ldd /tmp/test-native | grep -q 'not found\|/opt/gemix/native'; \
    done; \
    install -d /tmp/native-consumer; \
    cp /tmp/test-native.cpp /tmp/native-consumer/main.cpp; \
    printf '%s\n' \
      'cmake_minimum_required(VERSION 3.20)' \
      'project(native_consumer LANGUAGES CXX)' \
      'find_package(Native CONFIG REQUIRED)' \
      'add_executable(native_consumer main.cpp)' \
      'target_link_libraries(native_consumer PRIVATE Native::Native)' \
      > /tmp/native-consumer/CMakeLists.txt; \
    for sdk in "${NATIVE_GEMIX_SDK}" "${NATIVE_GEMIX_GEMD_SDK}"; do \
      rm -rf /tmp/native-consumer/build; \
      cmake -S /tmp/native-consumer -B /tmp/native-consumer/build \
        -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="$sdk"; \
      cmake --build /tmp/native-consumer/build; \
    done; \
    rm -rf /tmp/native-consumer /tmp/test-native /tmp/test-native.cpp; \
    rm -f /tmp/rasta.framebuffer /tmp/rasta-smoke.log /tmp/xvfb-error.log; \
    echo "All checks passed."
