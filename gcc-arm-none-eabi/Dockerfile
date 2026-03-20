# ARM bare-metal toolchain (arm-none-eabi) + OpenOCD on Ubuntu
FROM ubuntu:22.04

ARG IMG_VERSION=1.1.0

LABEL org.opencontainers.image.title="gcc-arm-none-eabi" \
      org.opencontainers.image.description="ARM bare-metal toolchain (arm-none-eabi) with newlib, GDB, OpenOCD, and build tools on Ubuntu 22.04." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later and others; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive

# Generic ARM bare-metal development stack only. Pico-specific SDK/tools live
# in the higher-level Raspberry Pi Pico image.
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    make \
    git \
    gdb-multiarch \
    openocd \
    pkg-config \
    ninja-build \
    python3 \
    python3-pip \
    python3-serial \
    python3-pyelftools \
    ca-certificates \
    curl \
    wget \
    xz-utils \
    tar \
    bash \
    file \
    usbutils \
    libusb-1.0-0 \
    libusb-1.0-0-dev \
    libhidapi-libusb0 \
    libhidapi-dev \
    gcc-arm-none-eabi \
    binutils-arm-none-eabi \
    libnewlib-arm-none-eabi \
    libstdc++-arm-none-eabi-dev \
    libstdc++-arm-none-eabi-newlib \
    && rm -rf /var/lib/apt/lists/*

# Toolchain location (binaries live in /usr/bin as arm-none-eabi-*)
ENV ARM_NONE_EABI_TOOLCHAIN_PATH=/usr \
    PICO_TOOLCHAIN_PATH=/usr \
    PATH="/usr/bin:${PATH}"

RUN mkdir -p /opt/arm-none-eabi/bin && \
    for b in /usr/bin/arm-none-eabi-*; do ln -sf "$b" /opt/arm-none-eabi/bin/; done

WORKDIR /work

# Sanity checks (toolchain + tiny C/C++ link + compat paths)
RUN set -e; \
  echo "=== ARM toolchain (Ubuntu) ==="; \
  for b in gcc g++ cpp as ld ar objcopy objdump size; do \
    which arm-none-eabi-$b >/dev/null && arm-none-eabi-$b --version | head -n1 || { echo "MISSING: arm-none-eabi-$b"; exit 1; }; \
  done; \
  echo "=== GDB ==="; \
  (which arm-none-eabi-gdb >/dev/null && arm-none-eabi-gdb --version | head -n1) || \
  (which gdb-multiarch >/dev/null && gdb-multiarch --version | head -n1) || true; \
  echo "=== Build tools ==="; cmake --version | head -n1; make --version | head -n1; ninja --version; \
  echo "=== OpenOCD ==="; openocd --version | head -n1; \
  echo "=== Paths ==="; \
  echo "ARM_NONE_EABI_TOOLCHAIN_PATH=${ARM_NONE_EABI_TOOLCHAIN_PATH}"; \
  echo "PICO_TOOLCHAIN_PATH=${PICO_TOOLCHAIN_PATH}"; \
  test -x /opt/arm-none-eabi/bin/arm-none-eabi-gcc && echo "/opt compat: OK -> $(readlink -f /opt/arm-none-eabi/bin/arm-none-eabi-gcc)"; \
  echo "libgcc: $(arm-none-eabi-gcc -print-target-libgcc-file-name)"; \
  echo "=== Tiny C compile/link test ==="; \
  printf 'int main(void){return 0;}\n' > /tmp/hello.c; \
  arm-none-eabi-gcc -mcpu=cortex-m0plus -mthumb -Os -ffunction-sections -fdata-sections \
    -Wl,--gc-sections -nostartfiles -specs=nosys.specs \
    -o /tmp/hello.elf /tmp/hello.c; \
  arm-none-eabi-objdump -f /tmp/hello.elf | head -n1; arm-none-eabi-size /tmp/hello.elf; \
  echo "=== Tiny C++ compile/link test (RP2040, libsupc++/libstdc++) ==="; \
  printf '#include <new>\nint main(){int* p=new int(5); delete p; return 0;}\n' > /tmp/hello.cpp; \
  arm-none-eabi-g++ -mcpu=cortex-m0plus -mthumb -Os -ffunction-sections -fdata-sections \
    -fno-exceptions -fno-rtti \
    -Wl,--gc-sections -nostartfiles -specs=nosys.specs \
    -o /tmp/hello++.elf /tmp/hello.cpp; \
  arm-none-eabi-objdump -f /tmp/hello++.elf | head -n1; arm-none-eabi-size /tmp/hello++.elf; \
  rm -f /tmp/hello.c /tmp/hello.elf /tmp/hello.cpp /tmp/hello++.elf; \
  echo "Image ready."
