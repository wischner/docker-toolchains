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
      gcc-arm-none-eabi binutils-arm-none-eabi newlib-arm-none-eabi \
      gdb-multiarch

# Toolchain location (binaries live in /usr/bin as arm-none-eabi-*)
ENV PICO_TOOLCHAIN_PATH=/usr
ENV PATH="/usr/bin:${PATH}"

WORKDIR /work

# Sanity checks (toolchain + tiny compile)
RUN set -e; \
    echo "=== ARM toolchain (Alpine native) ==="; \
    which arm-none-eabi-gcc && arm-none-eabi-gcc --version | head -n1; \
    which arm-none-eabi-gdb  && arm-none-eabi-gdb  --version | head -n1 || true; \
    echo "=== OpenOCD ==="; openocd --version | head -n1; \
    echo "=== Tiny compile/link test (RP2040 profile) ==="; \
    printf 'int main(void){return 0;}\n' > /tmp/hello.c; \
    arm-none-eabi-gcc -mcpu=cortex-m0plus -mthumb -Os -ffunction-sections -fdata-sections \
      -Wl,--gc-sections -nostartfiles -specs=nosys.specs \
      -o /tmp/hello.elf /tmp/hello.c; \
    arm-none-eabi-objdump -f /tmp/hello.elf | head -n1; \
    rm -f /tmp/hello.c /tmp/hello.elf; \
    echo "Image ready."
