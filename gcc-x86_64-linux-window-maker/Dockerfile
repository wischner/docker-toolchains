# GCC x86_64 Linux Window Maker / WINGs development toolchain (Ubuntu 22.04)
ARG BASE_IMAGE=wischner/gcc-x86_64-linux-x11:1.2.0
FROM ${BASE_IMAGE}

ARG IMG_VERSION=1.2.0
ARG WINDOW_MAKER_REPOSITORY=https://github.com/retro-vault/window-maker.git
ARG WINDOW_MAKER_REVISION=89338622679950dad5e3f5d2a39e78d58d60063d
ARG WINDOW_MAKER_VERSION=0.96.0

LABEL org.opencontainers.image.title="gcc-x86_64-linux-window-maker" \
      org.opencontainers.image.description="Complete GCC x86_64 Linux Window Maker and WINGs development toolchain layered on the Linux X11 base image." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}" \
      org.opencontainers.image.window-maker.source="${WINDOW_MAKER_REPOSITORY}" \
      org.opencontainers.image.window-maker.revision="${WINDOW_MAKER_REVISION}" \
      org.opencontainers.image.window-maker.version="${WINDOW_MAKER_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive
ENV WINDOW_MAKER_SOURCE=/usr/local/src/window-maker
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
ENV CMAKE_PREFIX_PATH=/usr/local

COPY patches/ /opt/window-maker-patches/
COPY sdk/ /opt/window-maker-sdk/

# The X11 base already supplies the compiler, debugger, CMake, Git, X11,
# Xft/fontconfig, common image libraries, Xvfb, and Xephyr. Keep the complete
# Window Maker requirement set explicit here so the derived image remains a
# self-documenting and stable primary development environment.
RUN apt-get update && apt-get install -y \
    ca-certificates \
    build-essential \
    cmake \
    pkg-config \
    git \
    gettext \
    libx11-dev \
    libxext-dev \
    libxinerama-dev \
    libxmu-dev \
    libxpm-dev \
    libxft-dev \
    libfontconfig1-dev \
    libxrandr-dev \
    libxres-dev \
    libpng-dev \
    libjpeg-dev \
    libtiff-dev \
    libgif-dev \
    libwebp-dev \
    libexif-dev \
    libpango1.0-dev \
    libmagickwand-dev \
    perl \
    python3 \
    python-is-python3 \
    x11-utils \
    x11-xserver-utils \
    xauth \
    xvfb \
    xserver-xephyr \
    xterm \
    && rm -rf /var/lib/apt/lists/*

# Fetch the pinned CMake-native source, apply the small full-feature build
# compatibility patch, and retain the patched checkout in the final image.
# The shared build installs every supported application, library, public
# header, tool, resource, translation, and manual. A second build contributes
# the four static SDK archives without replacing the shared executables.
RUN set -eux; \
    install -d "$WINDOW_MAKER_SOURCE"; \
    git -C "$WINDOW_MAKER_SOURCE" init; \
    git -C "$WINDOW_MAKER_SOURCE" remote add origin "$WINDOW_MAKER_REPOSITORY"; \
    git -C "$WINDOW_MAKER_SOURCE" fetch --depth 1 origin "$WINDOW_MAKER_REVISION"; \
    git -C "$WINDOW_MAKER_SOURCE" checkout --detach FETCH_HEAD; \
    test "$(git -C "$WINDOW_MAKER_SOURCE" rev-parse HEAD)" = "$WINDOW_MAKER_REVISION"; \
    git -C "$WINDOW_MAKER_SOURCE" apply \
      /opt/window-maker-patches/0001-fix-full-feature-cmake-build.patch; \
    git -C "$WINDOW_MAKER_SOURCE" diff --check; \
    shared_build=/tmp/window-maker-shared; \
    cmake -S "$WINDOW_MAKER_SOURCE" -B "$shared_build" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DWMAKER_DEV_TREE=OFF \
      -DBUILD_SHARED_LIBS=ON \
      -DWMAKER_RANDR=ON \
      -DWMAKER_PANGO=ON \
      -DWMAKER_MAGICK=ON \
      -DWMAKER_NLS=ON \
      -DWMAKER_BUILD_WPREFS=ON \
      -DWMAKER_BUILD_UTILS=ON \
      -DWMAKER_BUILD_WMLIB=ON \
      -DWMAKER_BUILD_EXAMPLES=ON; \
    grep -q '^#define USE_GIF 5$' "$shared_build/generated/config.h"; \
    for feature in \
      HAVE_EXIF I18N USE_GIF USE_JPEG USE_MAGICK USE_PANGO USE_PNG \
      USE_RANDR USE_TIFF USE_WEBP USE_XPM USE_XRES; do \
        grep -q "^#define ${feature} " "$shared_build/generated/config.h"; \
    done; \
    cmake --build "$shared_build" --parallel "$(nproc)"; \
    cmake --install "$shared_build"; \
    for program in \
      colorpick fontl puzzle testmywidget wings-tableview wmfile wmquery wtest \
      wmlib-wtest wraster-testdraw wraster-testgrad wraster-testrot wraster-view; do \
        install -m 0755 "$shared_build/stage/bin/$program" /usr/local/bin/; \
    done; \
    static_build=/tmp/window-maker-static; \
    cmake -S "$WINDOW_MAKER_SOURCE" -B "$static_build" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DWMAKER_DEV_TREE=OFF \
      -DBUILD_SHARED_LIBS=OFF \
      -DWMAKER_RANDR=ON \
      -DWMAKER_PANGO=ON \
      -DWMAKER_MAGICK=ON \
      -DWMAKER_NLS=OFF \
      -DWMAKER_BUILD_WPREFS=OFF \
      -DWMAKER_BUILD_UTILS=OFF \
      -DWMAKER_BUILD_WMLIB=ON \
      -DWMAKER_BUILD_EXAMPLES=OFF; \
    cmake --build "$static_build" --parallel "$(nproc)" \
      --target WINGs WUtil wraster WMaker; \
    for library in WINGs WUtil wraster WMaker; do \
        install -m 0644 "$static_build/stage/lib/lib${library}.a" /usr/local/lib/; \
    done; \
    install -d \
      /usr/local/bin \
      /usr/local/lib/pkgconfig \
      /usr/local/lib/cmake/WindowMaker \
      /usr/local/share/doc/window-maker; \
    install -m 0755 /opt/window-maker-sdk/bin/window-maker-xephyr /usr/local/bin/; \
    install -m 0644 /opt/window-maker-sdk/pkgconfig/*.pc /usr/local/lib/pkgconfig/; \
    install -m 0644 /opt/window-maker-sdk/cmake/WindowMakerConfig.cmake \
      /usr/local/lib/cmake/WindowMaker/WindowMakerConfig.cmake; \
    install -m 0644 \
      "$WINDOW_MAKER_SOURCE/COPYING" \
      "$WINDOW_MAKER_SOURCE/COPYING.WTFPL" \
      "$WINDOW_MAKER_SOURCE/README" \
      "$WINDOW_MAKER_SOURCE/docs/building/README.md" \
      /usr/local/share/doc/window-maker/; \
    install -m 0644 \
      /opt/window-maker-patches/0001-fix-full-feature-cmake-build.patch \
      /usr/local/share/doc/window-maker/; \
    sed -i 's/^Requires: wrlib WUtil$/Requires: wrlib WUtil pangoxft/' \
      /usr/local/lib/pkgconfig/WINGs.pc; \
    grep -q '^Requires: wrlib WUtil pangoxft$' \
      /usr/local/lib/pkgconfig/WINGs.pc; \
    printf '%s\n' \
      "repository=$WINDOW_MAKER_REPOSITORY" \
      "revision=$WINDOW_MAKER_REVISION" \
      "version=$WINDOW_MAKER_VERSION" \
      > /usr/local/share/doc/window-maker/SOURCE; \
    printf '%s\n' /usr/local/lib > /etc/ld.so.conf.d/window-maker.conf; \
    ldconfig; \
    rm -rf "$shared_build" "$static_build" \
      /opt/window-maker-patches /opt/window-maker-sdk

WORKDIR /work

# Build-time checks cover all features, the retained source, every public SDK
# family, shared and static consumers, applications, examples, and CMake.
RUN set -eux; \
    echo "=== Compiler and build tools ==="; \
      gcc --version; g++ --version; cmake --version; make --version; \
      git --version; pkg-config --version; gdb --version | head -1; \
    echo "=== Source and complete dependency set ==="; \
      test "$(git -C "$WINDOW_MAKER_SOURCE" rev-parse HEAD)" = "$WINDOW_MAKER_REVISION"; \
      test -f "$WINDOW_MAKER_SOURCE/CMakeLists.txt"; \
      dpkg-query -W \
        gettext libgif-dev libexif-dev libpango1.0-dev libmagickwand-dev \
        libxrandr-dev libxres-dev xserver-xephyr xvfb xterm; \
      pkg-config --exists \
        x11 xext xinerama xmu xpm xft fontconfig xrandr xres \
        libpng libjpeg libtiff-4 libwebp libexif pangoxft MagickWand; \
    echo "=== Window Maker SDK ==="; \
      test "$(pkg-config --modversion WINGs)" = "$WINDOW_MAKER_VERSION"; \
      pkg-config --exists WINGs WUtil wrlib wmlib; \
      pkg-config --exists WINGs-static WUtil-static wrlib-static wmlib-static; \
      test -f /usr/local/include/WINGs/WINGs.h; \
      test -f /usr/local/include/WINGs/WINGsP.h; \
      test -f /usr/local/include/WINGs/WUtil.h; \
      test -f /usr/local/include/wraster.h; \
      test -f /usr/local/include/WMaker.h; \
      for library in WINGs WUtil wraster WMaker; do \
        test -f "/usr/local/lib/lib${library}.so"; \
        test -f "/usr/local/lib/lib${library}.a"; \
      done; \
    echo "=== Window Maker applications, tools, examples, and resources ==="; \
      for program in \
        wmaker WPrefs wmagnify wmiv wmsetbg wmaker.inst wmgenmenu wmmenugen \
        wdread wdwrite geticonset seticons getstyle setstyle convertfonts \
        wxcopy wxpaste wkdemenu.pl wm-oldmenu2new window-maker-xephyr \
        colorpick fontl puzzle testmywidget wings-tableview wmfile wmquery \
        wtest wmlib-wtest wraster-testdraw wraster-testgrad wraster-testrot \
        wraster-view; do \
          command -v "$program"; \
      done; \
      test -d /usr/local/share/WindowMaker; \
      test -d /usr/local/share/WINGs; \
      test -d /usr/local/share/WPrefs; \
      test -d /usr/local/share/locale; \
      test -d /usr/local/share/man/man1; \
      test -d /usr/local/etc/WindowMaker; \
      test "$(wmaker --version)" = "Window Maker $WINDOW_MAKER_VERSION"; \
    echo "=== Shared and static pkg-config consumers ==="; \
      printf '#include <WINGs/WINGsP.h>\nint main(int argc,char **argv){WMInitializeApplication("test",&argc,argv);return 0;}\n' \
        > /tmp/test-wings.c; \
      gcc -Wall -Wextra -Werror -o /tmp/test-wings-shared /tmp/test-wings.c \
        $(pkg-config --cflags --libs WINGs); \
      gcc -Wall -Wextra -Werror -o /tmp/test-wings-static /tmp/test-wings.c \
        $(pkg-config --cflags --libs WINGs-static); \
      ! ldd /tmp/test-wings-static | grep -Eq 'lib(WINGs|WUtil|wraster)\.so'; \
    echo "=== CMake shared and static consumers ==="; \
      install -d /tmp/test-window-maker-cmake; \
      cp /tmp/test-wings.c /tmp/test-window-maker-cmake/main.c; \
      printf 'cmake_minimum_required(VERSION 3.16)\nproject(test_window_maker C)\nfind_package(WindowMaker CONFIG REQUIRED)\nadd_executable(test-shared main.c)\ntarget_link_libraries(test-shared PRIVATE WindowMaker::WINGs)\nadd_executable(test-static main.c)\ntarget_link_libraries(test-static PRIVATE WindowMaker::WINGs_static)\n' \
        > /tmp/test-window-maker-cmake/CMakeLists.txt; \
      cmake -S /tmp/test-window-maker-cmake -B /tmp/test-window-maker-cmake/build; \
      cmake --build /tmp/test-window-maker-cmake/build --parallel; \
      ! ldd /tmp/test-window-maker-cmake/build/test-static \
        | grep -Eq 'lib(WINGs|WUtil|wraster)\.so'; \
      rm -rf \
        /tmp/test-wings.c /tmp/test-wings-shared /tmp/test-wings-static \
        /tmp/test-window-maker-cmake; \
    echo "All checks passed."
