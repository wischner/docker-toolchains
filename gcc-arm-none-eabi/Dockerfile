# ARM bare-metal toolchain (arm-none-eabi) + OpenOCD on Alpine (single-stage)
FROM alpine:3.20

ARG IMG_VERSION=1.0.2

LABEL org.opencontainers.image.title="gcc-arm-none-eabi" \
      org.opencontainers.image.description="ARM bare-metal toolchain (arm-none-eabi) with OpenOCD, CMake, git on Alpine (musl-native toolchain)." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later and others; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

# Use Alpine’s native (musl) cross toolchain; no glibc shims needed.
# Packages: compiler + binutils + newlib (libc for bare metal) + gdb + OpenOCD + build utils
RUN apk add --no-cache \
    ca-certificates wget tar xz bash file \
    cmake make git \
    openocd usbutils libusb hidapi \
    gcc-arm-none-eabi g++-arm-none-eabi binutils-arm-none-eabi newlib-arm-none-eabi \
    gdb-multiarch

# Toolchain location (binaries live in /usr/bin as arm-none-eabi-*)
ENV PICO_TOOLCHAIN_PATH=/usr
RUN mkdir -p /opt/arm-none-eabi/bin && \
    for b in /usr/bin/arm-none-eabi-*; do ln -sf "$b" /opt/arm-none-eabi/bin/; done
ENV PATH="/usr/bin:${PATH}"

WORKDIR /work

# Sanity checks (toolchain + tiny C/C++ link + compat paths)
RUN set -e; \
  echo "=== ARM toolchain (Alpine native) ==="; \
  for b in gcc g++ as ld ar objcopy objdump size; do \
    which arm-none-eabi-$b >/dev/null && arm-none-eabi-$b --version | head -n1 || { echo "MISSING: arm-none-eabi-$b"; exit 1; }; \
  done; \
  echo "=== GDB ==="; \
  (which arm-none-eabi-gdb >/dev/null && arm-none-eabi-gdb --version | head -n1) || \
  (which gdb-multiarch >/dev/null && gdb-multiarch --version | head -n1) || true; \
  echo "=== Build tools ==="; cmake --version | head -n1; make --version | head -n1; \
  echo "=== OpenOCD ==="; openocd --version | head -n1; \
  echo "=== Paths ==="; \
  echo "PICO_TOOLCHAIN_PATH=${PICO_TOOLCHAIN_PATH}"; \
  test -x /opt/arm-none-eabi/bin/arm-none-eabi-gcc && echo "/opt compat: OK -> $(readlink -f /opt/arm-none-eabi/bin/arm-none-eabi-gcc)"; \
  echo "libgcc: $(arm-none-eabi-gcc -print-target-libgcc-file-name)"; \
  echo "=== Tiny C compile/link test (RP2040) ==="; \
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

