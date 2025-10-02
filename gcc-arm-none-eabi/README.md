# GCC ARM (arm-none-eabi) toolchain

This image is part of **Wischner Ltd. Toolchains**.

> **Pin your tags.** Use a versioned tag (e.g. `:1.0.3`) instead of `:latest` to avoid accidental regressions.

## What it is
ARM bare‑metal GCC toolchain (`arm-none-eabi`) with **GDB** and **OpenOCD** for general embedded development on Alpine Linux (musl).  
Supports building and debugging Cortex‑M and other ARM microcontrollers.

This image uses **Alpine’s native cross toolchain** (musl) — no glibc shims required.

## Installed components
- Alpine’s `arm-none-eabi` toolchain (**GCC, G++, binutils, newlib**)
  - `arm-none-eabi-gcc`, `arm-none-eabi-g++`, `arm-none-eabi-as`, `arm-none-eabi-ld`,
    `arm-none-eabi-objcopy`, `arm-none-eabi-objdump`, `arm-none-eabi-size`
- Debuggers & tools
  - `gdb-multiarch` (GDB for cross targets)
  - `openocd` (mainline)
- Build utilities
  - `cmake`, `make`, `git`, `bash`, `file`
- USB helpers
  - `usbutils` (`lsusb`), `libusb`, `hidapi`

### Paths & compatibility
- Toolchain lives in: **`/usr/bin`** (e.g. `/usr/bin/arm-none-eabi-gcc`)
- Convenience/legacy path: **`/opt/arm-none-eabi/bin`** (symlinks to `/usr/bin/arm-none-eabi-*`)
- Environment exported:
  - `PICO_TOOLCHAIN_PATH=/usr`
  - `PATH=/usr/bin:$PATH`
- Default working directory: `/work`

> **Version note:** Tool versions come from the Alpine 3.20 repositories used to build this image.  
> Check at runtime:
> ```bash
> arm-none-eabi-gcc --version
> gdb-multiarch --version
> openocd --version
> ```

## Usage

### Quick start (interactive shell)
```bash
docker run --rm -it   -v "$(pwd)":/work -w /work   wischner/gcc-arm-none-eabi:1.0.3 bash
```

### Compile a minimal program
```bash
cat > hello.c <<'EOF'
int main(void) { return 0; }
EOF

arm-none-eabi-gcc -mcpu=cortex-m3 -mthumb -Os   -ffunction-sections -fdata-sections   -Wl,--gc-sections -nostartfiles -specs=nosys.specs   -o hello.elf hello.c

arm-none-eabi-size hello.elf
```

## Debugging with OpenOCD + GDB
(Adjust interface/target scripts to your hardware.)
```bash
# Terminal 1
openocd -f interface/stlink.cfg -f target/stm32f1x.cfg
```
```bash
# Terminal 2
gdb-multiarch hello.elf
(gdb) target remote localhost:3333
(gdb) monitor reset init
(gdb) load
(gdb) continue
```

## Notes for Raspberry Pi Pico / Pico W (RP2040)
- This base image exposes the toolchain in `/usr` and sets `PICO_TOOLCHAIN_PATH=/usr`.  
  You normally **don’t** need to pass it to CMake, but you can with:
  ```bash
  -DPICO_TOOLCHAIN_PATH=/usr
  ```
- If you want the SDK, `picotool`, and `pioasm` baked in, use the higher‑level image:
  **`wischner/gcc-arm-none-eabi-rpi-pico`**.

## Build‑time arguments
- `IMG_VERSION` (used only for the image label)

Example:
```bash
docker build --build-arg IMG_VERSION=1.0.3 -t wischner/gcc-arm-none-eabi:1.0.3 .
```

## Support & contributions
For bug reports, feature requests, or questions, please use the issue tracker:  
<https://github.com/wischner/docker-toolchains/issues>