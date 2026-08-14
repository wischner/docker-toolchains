# GCC x86_64 Linux Open Motif development toolchain (Ubuntu 22.04)
ARG BASE_IMAGE=wischner/gcc-x86_64-linux-x11:1.1.1
FROM ${BASE_IMAGE}

ARG IMG_VERSION=1.1.1

LABEL org.opencontainers.image.title="gcc-x86_64-linux-motif" \
      org.opencontainers.image.description="GCC x86_64 Linux Open Motif development toolchain layered on the Linux X11 base image." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
ENV CMAKE_PREFIX_PATH=/usr/local

COPY sdk/ /opt/motif-sdk/

# Open Motif development stack, compiler tooling, and legacy runtime helpers.
RUN apt-get update && apt-get install -y \
    libmotif-dev \
    uil \
    mwm \
    xbitmaps \
    libglw1-mesa-dev \
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
    install -m 0644 /opt/motif-sdk/pkgconfig/*.pc /usr/local/lib/pkgconfig/; \
    install -m 0644 /opt/motif-sdk/cmake/MotifConfig.cmake \
      /usr/local/lib/cmake/Motif/MotifConfig.cmake; \
    rm -rf /opt/motif-sdk

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
    echo "All checks passed."
