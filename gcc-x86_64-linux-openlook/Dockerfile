# GCC x86_64 Linux OpenLook / XView development toolchain (Ubuntu 22.04)
ARG BASE_IMAGE=wischner/gcc-x86_64-linux-x11:1.4.0
FROM ${BASE_IMAGE}

ARG IMG_VERSION=1.2.0
ARG OPENLOOK_REPOSITORY=https://github.com/retro-vault/open-look.git
ARG OPENLOOK_REVISION=6d71812d9cdfe3b7efca7f54f17bc905f8b87d41

LABEL org.opencontainers.image.title="gcc-x86_64-linux-openlook" \
      org.opencontainers.image.description="Complete GCC x86_64 Linux OpenLook/XView development toolchain layered on the Linux X11 base image." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="See component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}" \
      org.opencontainers.image.openlook.source="${OPENLOOK_REPOSITORY}" \
      org.opencontainers.image.openlook.revision="${OPENLOOK_REVISION}"

ENV DEBIAN_FRONTEND=noninteractive
ENV OPENWINHOME=/usr/openwin
ENV PATH=/usr/openwin/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/openwin/lib
ENV PKG_CONFIG_PATH=/usr/openwin/lib/pkgconfig
ENV CMAKE_PREFIX_PATH=/usr/openwin
ENV MANPATH=/usr/openwin/share/man:

COPY sdk/ /opt/openlook-sdk/

# libtirpc and Boost are the development dependencies this port needs beyond
# the X11 base. XView headers include <rpc/rpc.h> and <boost/preprocessor.hpp>.
# File Manager links libXpm, which the base already provides. OpenLook itself
# is the CMake-native retro-vault port; no imake toolchain is required.
#
# The font set, File Manager help, menus, manuals, locale data, and the
# sun-cmd terminfo entry ship with the source tree. CMake install places
# them under OPENWINHOME. The defaults name both the Adobe Helvetica and
# B&H Lucida families, and XView falls back to the server's wide fixed font
# when either is absent, which mis-sizes every control. The build check
# near the end of this file asserts both are present, so a source revision
# that drops them fails here rather than on screen.
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libboost-dev \
    libtirpc-dev \
    && rm -rf /var/lib/apt/lists/*

# Install the complete OPENWINHOME tree from the upstream CMake rules:
# libraries, headers (including xview_private), applications, fonts, images,
# bitmaps, menus, help, manuals, locales, and terminfo. The compiled default
# OPENWINHOME matches the image prefix.
RUN set -eux; \
    srcdir="$(mktemp -d)"; \
    git -C "$srcdir" init; \
    git -C "$srcdir" remote add origin "$OPENLOOK_REPOSITORY"; \
    git -C "$srcdir" fetch --depth 1 origin "$OPENLOOK_REVISION"; \
    git -C "$srcdir" checkout --detach FETCH_HEAD; \
    test "$(git -C "$srcdir" rev-parse HEAD)" = "$OPENLOOK_REVISION"; \
    cmake -S "$srcdir" -B "$srcdir/build" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX="$OPENWINHOME"; \
    cmake --build "$srcdir/build" --parallel "$(nproc)"; \
    cmake --install "$srcdir/build"; \
    find "$srcdir/include" -type f -printf '%P\n' | while IFS= read -r header; do \
      test -f "$OPENWINHOME/include/$header"; \
    done; \
    install -d \
      "$OPENWINHOME/bin" \
      "$OPENWINHOME/lib/pkgconfig" \
      "$OPENWINHOME/lib/cmake/OpenLook" \
      "$OPENWINHOME/share/doc/open-look"; \
    install -m 0755 /opt/openlook-sdk/bin/openlook-xephyr "$OPENWINHOME/bin/"; \
    install -m 0644 /opt/openlook-sdk/pkgconfig/*.pc "$OPENWINHOME/lib/pkgconfig/"; \
    install -m 0644 /opt/openlook-sdk/cmake/OpenLookConfig.cmake \
      "$OPENWINHOME/lib/cmake/OpenLook/OpenLookConfig.cmake"; \
    printf '%s\n' "$OPENWINHOME/lib" > /etc/ld.so.conf.d/openlook.conf; \
    printf '%s\n' \
      "repository=$OPENLOOK_REPOSITORY" \
      "revision=$OPENLOOK_REVISION" \
      > "$OPENWINHOME/share/doc/open-look/SOURCE"; \
    ldconfig; \
    rm -rf "$srcdir" /opt/openlook-sdk

WORKDIR /work

# Build-time checks cover the compiler tools, all SDK families, pkg-config,
# and the CMake imported target. Runtime GUI behavior is tested after build
# with a generated application under Xephyr.
RUN set -eux; \
    echo "=== Compiler and build tools ==="; \
      gcc --version; g++ --version; cmake --version; make --version; \
      git --version; pkg-config --version; gdb --version | head -1; \
    echo "=== X11 and test servers ==="; \
      pkg-config --modversion x11; command -v Xvfb; command -v Xephyr; \
    echo "=== OpenLook headers ==="; \
      test -f /usr/openwin/include/olgx/olgx.h; \
      test -f /usr/openwin/include/pixrect/pixrect.h; \
      test -f /usr/openwin/include/xview/xview.h; \
      test -f /usr/openwin/include/xview_private/attr_impl.h; \
    echo "=== OpenLook fonts ==="; \
      for leaf in misc 75dpi 100dpi; do \
        test -s "/usr/openwin/share/fonts/openlook/bdf/$leaf/fonts.dir"; \
      done; \
      grep -qi -- '-adobe-helvetica-' \
        /usr/openwin/share/fonts/openlook/bdf/75dpi/fonts.dir; \
      grep -qi -- '-b&h-lucida-' \
        /usr/openwin/share/fonts/openlook/bdf/75dpi/fonts.dir; \
      test -d /usr/openwin/include/images; \
      test -d /usr/openwin/include/bitmaps; \
      test -d /usr/openwin/include/X11/bitmaps; \
    echo "=== OpenLook libraries and applications ==="; \
      test -f /usr/openwin/lib/libxview.so; test -f /usr/openwin/lib/libxview.a; \
      test -f /usr/openwin/lib/libolgx.so; test -f /usr/openwin/lib/libolgx.a; \
      test -f /usr/openwin/lib/openwin-menu; \
      test -f /usr/openwin/lib/openwin-menu-programs; \
      test -f /usr/openwin/lib/app-defaults/Olwm; \
      test -f /usr/openwin/lib/.text_extras_menu; \
      test -f /usr/openwin/lib/help/filemgr.info; \
      test -f /usr/openwin/share/man/man1/filemgr.1; \
      test -d /usr/openwin/share/locale/C/props; \
      TERMINFO=/usr/openwin/share/terminfo infocmp sun-cmd >/dev/null; \
      test -x /usr/openwin/use-openwinhome.sh; \
      command -v olwm; command -v openlook-xephyr; command -v filemgr; command -v clock; \
      command -v cmdtool; command -v textedit; command -v props; \
      command -v olwmslave; command -v xtoolplaces; \
      pkg-config --exists xview olgx; \
    echo "=== pkg-config compile test ==="; \
    printf '#include <xview/xview.h>\nint main(int argc, char **argv){xv_init(XV_INIT_ARGC_PTR_ARGV, &argc, argv, 0); return 0;}\n' > /tmp/test-xview.c; \
    gcc -o /tmp/test-xview /tmp/test-xview.c $(pkg-config --cflags --libs xview); \
    echo "=== CMake compile test ==="; \
    mkdir -p /tmp/test-openlook-cmake; \
    cp /tmp/test-xview.c /tmp/test-openlook-cmake/main.c; \
    printf 'cmake_minimum_required(VERSION 3.16)\nproject(test_openlook C)\nfind_package(OpenLook CONFIG REQUIRED)\nadd_executable(test-openlook main.c)\ntarget_link_libraries(test-openlook PRIVATE OpenLook::xview)\n' > /tmp/test-openlook-cmake/CMakeLists.txt; \
    cmake -S /tmp/test-openlook-cmake -B /tmp/test-openlook-cmake/build; \
    cmake --build /tmp/test-openlook-cmake/build --parallel; \
    rm -rf /tmp/test-xview /tmp/test-xview.c /tmp/test-openlook-cmake; \
    echo "All checks passed."
