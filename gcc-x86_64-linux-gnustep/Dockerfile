# GCC x86_64 Linux GNUstep development toolchain (Ubuntu 22.04)
ARG BASE_IMAGE=wischner/gcc-x86_64-linux-x11:1.0.0
FROM ${BASE_IMAGE}

ARG IMG_VERSION=1.0.0

LABEL org.opencontainers.image.title="gcc-x86_64-linux-gnustep" \
      org.opencontainers.image.description="GCC x86_64 Linux GNUstep development toolchain layered on the Linux X11 base image." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive

# GNUstep build system, Objective-C / Objective-C++ compilers, IDE tools,
# the preferred cairo backend, and common GNUstep development frameworks.
RUN apt-get update && apt-get install -y \
    gnustep-devel \
    gnustep-back0.29-cairo \
    gobjc++ \
    libgorm-dev \
    librenaissance0-dev \
    && rm -rf /var/lib/apt/lists/*

# Load GNUstep's environment automatically for login shells.
RUN printf '%s\n' '. /usr/share/GNUstep/Makefiles/GNUstep.sh' > /etc/profile.d/gnustep.sh

WORKDIR /work

# Sanity checks
RUN bash -lc 'set -e; \
    echo "=== Compiler ==="; gcc --version; g++ --version; \
    echo "=== CMake ==="; cmake --version; \
    echo "=== pkg-config ==="; pkg-config --version; \
    echo "=== GDB ==="; gdb --version | head -1; \
    echo "=== Base X11 ==="; pkg-config --modversion x11; \
    echo "=== GNUstep environment ==="; \
    . /usr/share/GNUstep/Makefiles/GNUstep.sh; \
    echo "$GNUSTEP_MAKEFILES"; \
    echo "=== gnustep-config ==="; command -v gnustep-config; \
    echo "=== gnustep-make ==="; dpkg-query -W -f='"'"'${Version}\n'"'"' gnustep-make; \
    echo "=== GNUstep Base dev ==="; dpkg-query -W -f='"'"'${Version}\n'"'"' libgnustep-base-dev; \
    echo "=== GNUstep GUI dev ==="; dpkg-query -W -f='"'"'${Version}\n'"'"' libgnustep-gui-dev; \
    echo "=== GNUstep IDE tools ==="; dpkg-query -W -f='"'"'${Version}\n'"'"' gorm.app projectcenter.app; \
    echo "=== GNUstep backend ==="; dpkg-query -W -f='"'"'${Version}\n'"'"' gnustep-back0.29-cairo; \
    echo "--- Compile tests ---"; \
    printf "#import <Foundation/Foundation.h>\nint main(void){NSAutoreleasePool *pool=[NSAutoreleasePool new]; NSLog(@\"GNUstep Foundation OK\"); [pool drain]; return 0;}\n" > /tmp/test-base.m; \
    gcc -o /tmp/test-base /tmp/test-base.m $(gnustep-config --objc-flags) $(gnustep-config --base-libs); \
    printf "#import <AppKit/AppKit.h>\nint main(int argc, char **argv){[NSApplication sharedApplication]; return 0;}\n" > /tmp/test-gui.m; \
    gcc -o /tmp/test-gui /tmp/test-gui.m $(gnustep-config --objc-flags) $(gnustep-config --gui-libs); \
    printf "#import <Foundation/Foundation.h>\nint main(void){return 0;}\n" > /tmp/test-objcxx.mm; \
    g++ -o /tmp/test-objcxx /tmp/test-objcxx.mm $(gnustep-config --objc-flags) $(gnustep-config --base-libs); \
    mkdir -p /tmp/gnustep-make-test; \
    cd /tmp/gnustep-make-test; \
    printf "include \$(GNUSTEP_MAKEFILES)/common.make\nTOOL_NAME = gstest\ngstest_OBJC_FILES = main.m\ninclude \$(GNUSTEP_MAKEFILES)/tool.make\n" > GNUmakefile; \
    printf "#import <Foundation/Foundation.h>\nint main(void){NSAutoreleasePool *pool=[NSAutoreleasePool new]; [pool drain]; return 0;}\n" > main.m; \
    make; \
    rm -rf /tmp/test-base /tmp/test-base.m /tmp/test-gui /tmp/test-gui.m /tmp/test-objcxx /tmp/test-objcxx.mm /tmp/gnustep-make-test; \
    echo "All checks passed."'
