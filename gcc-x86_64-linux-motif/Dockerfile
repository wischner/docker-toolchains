# GCC x86_64 Linux Open Motif development toolchain (Ubuntu 22.04)
ARG BASE_IMAGE=wischner/gcc-x86_64-linux-x11:1.0.0
FROM ${BASE_IMAGE}

ARG IMG_VERSION=1.0.0

LABEL org.opencontainers.image.title="gcc-x86_64-linux-motif" \
      org.opencontainers.image.description="GCC x86_64 Linux Open Motif development toolchain layered on the Linux X11 base image." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive

# Open Motif development stack, compiler tooling, and legacy runtime helpers.
RUN apt-get update && apt-get install -y \
    libmotif-dev \
    uil \
    mwm \
    xbitmaps \
    libglw1-mesa-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work

# Sanity checks
RUN echo "=== Compiler ===" && gcc --version && g++ --version \
 && echo "=== CMake ===" && cmake --version \
 && echo "=== pkg-config ===" && pkg-config --version \
 && echo "=== GDB ===" && gdb --version | head -1 \
 && echo "=== Base X11 ===" && pkg-config --modversion x11 \
 && echo "=== Motif dev package ===" && dpkg-query -W -f='${Version}\n' libmotif-dev \
 && echo "=== Motif runtime library ===" && dpkg-query -W -f='${Version}\n' libxm4 \
 && echo "=== UIL compiler ===" && command -v uil \
 && echo "=== Motif window manager ===" && command -v mwm \
 && echo "=== GLw Motif headers ===" && test -f /usr/include/GL/GLwMDrawA.h \
 && echo "--- Compile tests ---" \
 && printf '#include <Xm/Xm.h>\n#include <Xm/PushB.h>\nint main(int argc, char **argv){XtAppContext app;Widget top=XtVaAppInitialize(&app,"MotifTest",NULL,0,&argc,argv,NULL,NULL);Widget button=XtVaCreateManagedWidget("hello",xmPushButtonWidgetClass,top,NULL);XtDestroyWidget(button);XtDestroyWidget(top);return 0;}\n' > /tmp/test-motif.c \
 && gcc -o /tmp/test-motif /tmp/test-motif.c -lXm -lXt -lX11 \
 && printf '#include <Xm/Xm.h>\n#include <GL/GLwMDrawA.h>\nint main(void){WidgetClass wc=glwMDrawingAreaWidgetClass;return wc == (WidgetClass)0;}\n' > /tmp/test-glw.c \
 && gcc -c -o /tmp/test-glw.o /tmp/test-glw.c \
 && rm -f /tmp/test-motif /tmp/test-motif.c /tmp/test-glw.o /tmp/test-glw.c \
 && echo "All checks passed."
