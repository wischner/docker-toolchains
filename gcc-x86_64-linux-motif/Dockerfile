# GCC x86_64 Linux Open Motif development toolchain (Ubuntu 22.04)
ARG BASE_IMAGE=wischner/gcc-x86_64-linux-x11:1.6.0
FROM ${BASE_IMAGE}

ARG IMG_VERSION=1.4.1
ARG CDE_REPOSITORY=https://github.com/retro-vault/cde.git
ARG CDE_REVISION=a0652afb351fb68035f9af97a72a001b9fedd61a
ARG CDE_VERSION=2.5.3

LABEL org.opencontainers.image.title="gcc-x86_64-linux-motif" \
      org.opencontainers.image.description="GCC x86_64 Linux Open Motif and CDE development toolchain layered on the Linux X11 base image." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}" \
      org.opencontainers.image.cde.source="${CDE_REPOSITORY}" \
      org.opencontainers.image.cde.revision="${CDE_REVISION}" \
      org.opencontainers.image.cde.version="${CDE_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
ENV CMAKE_PREFIX_PATH=/usr/local
ENV PATH=/usr/dt/bin:${PATH}

COPY sdk/ /opt/motif-sdk/

# Open Motif development stack, compiler tooling, and legacy runtime helpers.
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libmotif-dev \
    uil \
    mwm \
    xbitmaps \
    libglw1-mesa-dev \
    libtirpc-dev \
    rpcsvc-proto \
    && rm -rf /var/lib/apt/lists/*

# Mesa's legacy GLw header declares its WidgetClass variables as tentative
# definitions. GCC 10+ defaults to -fno-common, which makes a static GLw link
# fail with duplicate symbols. These are declarations and must be extern.
# Install modern CMake/pkg-config metadata plus a self-contained GUI runner.
RUN set -eux; \
    sed -i -E \
      's/^GLAPI WidgetClass (glw(M)?DrawingAreaWidgetClass);$/extern WidgetClass \1;/' \
      /usr/include/GL/GLwDrawA.h; \
    grep -q '^extern WidgetClass glwDrawingAreaWidgetClass;' /usr/include/GL/GLwDrawA.h; \
    grep -q '^extern WidgetClass glwMDrawingAreaWidgetClass;' /usr/include/GL/GLwDrawA.h; \
    install -d \
      /usr/local/bin \
      /usr/local/lib/pkgconfig \
      /usr/local/lib/cmake/Motif; \
    install -m 0755 /opt/motif-sdk/bin/motif-xephyr /usr/local/bin/; \
    install -m 0755 /opt/motif-sdk/bin/cde-xephyr /usr/local/bin/; \
    install -m 0644 /opt/motif-sdk/pkgconfig/*.pc /usr/local/lib/pkgconfig/; \
    install -m 0644 /opt/motif-sdk/cmake/MotifConfig.cmake \
      /usr/local/lib/cmake/Motif/MotifConfig.cmake; \
    rm -rf /opt/motif-sdk

# Build the complete CDE 2.5.3 desktop from the pinned CMake port and install
# it at the classic /usr/dt prefix. Runtime paths are compiled into the
# programs, so the prefix is fixed before the build. The source tree requires
# its build directory to live under build/. The X11 base already supplies
# Motif, PAM, JPEG, LMDB, Tcl, ksh, bison, flex, onsgmls, and compress.
# NCFGen validates styles through validator, which opens
# <prefix>/share/dt/dtdocbook/spec/*.feature.spec. Those files are installed
# only by cmake --install, but the information-library targets run during
# cmake --build, so the spec directory has to be staged first. The locale
# targets also share the documentation helper symlinks, so those are built
# before the parallel build.
RUN set -eux; \
    src=/tmp/cde-src; \
    install -d "$src"; \
    git -C "$src" init; \
    git -C "$src" remote add origin "$CDE_REPOSITORY"; \
    git -C "$src" fetch --depth 1 origin "$CDE_REVISION"; \
    git -C "$src" checkout --detach FETCH_HEAD; \
    test "$(git -C "$src" rev-parse HEAD)" = "$CDE_REVISION"; \
    cmake -S "$src" -B "$src/build/linux" -G "Unix Makefiles" \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING=OFF \
      -DCMAKE_INSTALL_PREFIX=/usr/dt; \
    install -d /usr/dt/share/dt/dtdocbook; \
    cp -a "$src/src/dtdocbook/spec" /usr/dt/share/dt/dtdocbook/spec; \
    cmake --build "$src/build/linux" --target docbook_build_helpers --parallel 1; \
    cmake --build "$src/build/linux" --parallel "$(nproc)"; \
    cmake --install "$src/build/linux"; \
    printf '%s\n' \
      "version=${CDE_VERSION}" \
      "revision=${CDE_REVISION}" \
      "repository=${CDE_REPOSITORY}" \
      > /usr/dt/share/doc/cde/SOURCE; \
    echo /usr/dt/lib > /etc/ld.so.conf.d/cde.conf; \
    ldconfig; \
    install -d /etc/pam.d; \
    install -m 0644 /usr/dt/etc/pam.d/dtlogin /etc/pam.d/dtlogin; \
    install -m 0644 /usr/dt/etc/pam.d/dtsession /etc/pam.d/dtsession; \
    rm -rf "$src"

WORKDIR /work

# Build-time checks cover every library family, shared and static metadata,
# CMake targets, UIL generation, the window manager, and nested X tooling.
# A real GUI is launched under mwm/Xephyr after the image build.
RUN set -eux; \
    echo "=== Compiler and build tools ==="; \
      gcc --version; g++ --version; cmake --version; make --version; \
      git --version; pkg-config --version; gdb --version | head -1; \
    echo "=== X11 and test servers ==="; \
      pkg-config --modversion x11; command -v Xvfb; command -v Xephyr; \
    echo "=== Motif packages, tools, headers, and resources ==="; \
      dpkg-query -W -f='${Version}\n' libmotif-dev libxm4 libmrm4 libuil4; \
      command -v uil; command -v mwm; command -v xmbind; command -v motif-xephyr; \
      command -v cde-xephyr; \
      test -f /usr/include/Xm/Xm.h; test -f /usr/include/Mrm/MrmPublic.h; \
      test -f /usr/include/uil/Uil.h; test -f /usr/include/GL/GLwMDrawA.h; \
      test -f /etc/X11/mwm/system.mwmrc; \
      test -f /usr/share/X11/bindings/xmbind.alias; \
    echo "=== Shared and static libraries ==="; \
      for library in Xm Mrm Uil GLw; do \
        test -f "/usr/lib/x86_64-linux-gnu/lib${library}.so"; \
        test -f "/usr/lib/x86_64-linux-gnu/lib${library}.a"; \
      done; \
    echo "=== pkg-config metadata ==="; \
      pkg-config --exists motif xm mrm uil glw; \
      pkg-config --exists motif-static xm-static mrm-static uil-static glw-static; \
    echo "=== UIL compiler ==="; \
      printf 'module test names = case_sensitive object button : XmPushButton { }; end module;\n' \
        > /tmp/test-motif.uil; \
      uil /tmp/test-motif.uil -o /tmp/test-motif.uid; \
      test -s /tmp/test-motif.uid; \
    echo "=== Shared and static pkg-config consumers ==="; \
      printf '#include <Xm/Xm.h>\n#include <Xm/PushB.h>\nint main(int argc,char **argv){XtAppContext app;Widget top=XtVaAppInitialize(&app,"MotifTest",NULL,0,&argc,argv,NULL,NULL);Widget child=XtVaCreateManagedWidget("button",xmPushButtonWidgetClass,top,NULL);XtDestroyWidget(child);XtDestroyWidget(top);return 0;}\n' \
        > /tmp/test-motif.c; \
      gcc -Wall -Wextra -Werror -o /tmp/test-motif-shared /tmp/test-motif.c \
        $(pkg-config --cflags --libs xm); \
      gcc -Wall -Wextra -Werror -o /tmp/test-motif-static /tmp/test-motif.c \
        $(pkg-config --cflags --libs xm-static); \
      ! ldd /tmp/test-motif-static | grep -q 'libXm.so'; \
      printf '#include <Xm/Xm.h>\n#include <GL/GLwMDrawA.h>\nint main(int argc,char **argv){if(argc==123)(void)GLwCreateMDrawingArea(NULL,argv[0],NULL,0);return 0;}\n' \
        > /tmp/test-glw.c; \
      gcc -Wall -Wextra -Werror -o /tmp/test-glw-static /tmp/test-glw.c \
        $(pkg-config --cflags --libs glw-static); \
      ! ldd /tmp/test-glw-static | grep -q 'libGLw.so'; \
    echo "=== CMake shared and static targets ==="; \
      install -d /tmp/test-motif-cmake; \
      cp /tmp/test-motif.c /tmp/test-motif-cmake/main.c; \
      printf 'cmake_minimum_required(VERSION 3.16)\nproject(test_motif C)\nfind_package(Motif CONFIG REQUIRED)\nadd_executable(test-shared main.c)\ntarget_link_libraries(test-shared PRIVATE Motif::Xm)\nadd_executable(test-static main.c)\ntarget_link_libraries(test-static PRIVATE Motif::Xm_static)\n' \
        > /tmp/test-motif-cmake/CMakeLists.txt; \
      cmake -S /tmp/test-motif-cmake -B /tmp/test-motif-cmake/build; \
      cmake --build /tmp/test-motif-cmake/build --parallel; \
      ! ldd /tmp/test-motif-cmake/build/test-static | grep -q 'libXm.so'; \
      rm -rf \
        /tmp/test-motif.c /tmp/test-motif.uil /tmp/test-motif.uid \
        /tmp/test-motif-shared /tmp/test-motif-static \
        /tmp/test-glw.c /tmp/test-glw-static /tmp/test-motif-cmake; \
    echo "=== CDE ${CDE_VERSION} ==="; \
      test -x /usr/dt/bin/dtwm; test -x /usr/dt/bin/dtfile; \
      test -x /usr/dt/bin/dtterm; test -x /usr/dt/bin/dtpad; \
      test -x /usr/dt/bin/dtmail; test -x /usr/dt/bin/dtcm; \
      test -x /usr/dt/bin/dtcalc; test -x /usr/dt/bin/dtstyle; \
      test -x /usr/dt/bin/dticon; test -x /usr/dt/bin/dtbuilder; \
      test -x /usr/dt/bin/dthelpview; test -x /usr/dt/bin/dthelpgen; \
      test -x /usr/dt/bin/dtlogin; test -x /usr/dt/bin/dtsession; \
      test -x /usr/dt/bin/Xsession; test -x /usr/dt/bin/dtksh; \
      test -x /usr/dt/bin/dtaction; test -x /usr/dt/bin/dtcreate; \
      test -x /usr/dt/libexec/cde/rpc.cmsd; \
      test -x /usr/dt/libexec/cde/rpc.ttdbserver; \
      test -x /usr/dt/libexec/cde/xephyr-resize; \
      test -f /usr/dt/include/Dt/Dt.h; \
      grep -q 'CDE Version 2.5.3' /usr/dt/include/Dt/Dt.h; \
      grep -q "^revision=${CDE_REVISION}$" /usr/dt/share/doc/cde/SOURCE; \
      for library in DtSvc DtHelp DtWidget DtTerm DtMmdb tt; do \
        test -e "/usr/dt/lib/lib${library}.so"; \
      done; \
      test -f /usr/dt/share/dt/fontaliases/dtinfo.pcf.gz; \
      test -s /usr/dt/share/dt/fontaliases/fonts.dir; \
      for locale in en_US.UTF-8 de_DE.UTF-8 es_ES.UTF-8 fr_FR.UTF-8 it_IT.UTF-8 ja_JP.UTF-8; do \
        test -d "/usr/dt/share/dt/infolib/${locale}/cde.dti"; \
        test -n "$(find "/usr/dt/share/dt/appconfig/help/${locale}" -name '*.sdl' -print -quit)"; \
      done; \
      test -L /usr/dt/share/dt/infolib/C; \
      test -L /usr/dt/share/dt/appconfig/help/C; \
      test -f /usr/dt/etc/pam.d/dtlogin; test -f /etc/pam.d/dtlogin; \
      test -f /usr/dt/etc/pam.d/dtsession; test -f /etc/pam.d/dtsession; \
      printf '#include <Dt/Dt.h>\nint main(int argc,char **argv){if(argc==123)(void)DtInitialize(NULL,NULL,argv[0],argv[0]);return 0;}\n' \
        > /tmp/test-cde.c; \
      gcc -Wall -Wextra -Werror -o /tmp/test-cde /tmp/test-cde.c \
        -I/usr/dt/include -L/usr/dt/lib -lDtSvc -lXm -lXt -lX11; \
      rm -f /tmp/test-cde /tmp/test-cde.c; \
    echo "All checks passed."
