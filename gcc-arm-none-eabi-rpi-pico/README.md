# GCC ARM for Raspberry Pi Pico / Pico W

This image is part of **Wischner Ltd. Toolchains** and extends `wischner/gcc-arm-none-eabi` with Pico/Pico W utilities.  
It **ships the Pico SDK** and builds the essential host tools.

## What it is
ARM bare-metal GCC toolchain (`arm-none-eabi`) with **Pico-specific tools** for building, flashing, and debugging RP2040 projects over SWD (OpenOCD) or BOOTSEL USB (picotool).

## Installed components
- Alpine’s `arm-none-eabi` toolchain (GCC, G++, binutils, newlib)  
  `arm-none-eabi-gcc`, `arm-none-eabi-g++`, `arm-none-eabi-as`, `arm-none-eabi-ld`, `arm-none-eabi-gdb` (via `gdb-multiarch`)
- OpenOCD (mainline, from base image)
- **Pico SDK** baked at `/opt/pico-sdk` (default tag: **2.1.0**)
- **pico-extras** baked at `/opt/pico-extras` (default tag: **2.1.0**; falls back to default branch if missing)
- **Host tools**
  - `pioasm` (built from SDK)
  - `picotool` (built against the baked SDK; handles BOOTSEL ops and UF2 conversion)
- Python & helpers: `python3`, `py3-pyserial`, `py3-elftools`
- Build tools & libs: `cmake`, `make` (via `build-base`), `git`, `git-lfs`, `ccache`, `pkgconf`
- USB/debug libs: `libusb`, `hidapi`, `libftdi1`
- Kernel headers (`linux-headers`) for `picotool`’s whereami dependency

> **Version note:** Toolchain and OpenOCD versions come from the Alpine 3.20 repositories in the base image.  
> Check at runtime:
> ```bash
> arm-none-eabi-gcc --version
> gdb-multiarch --version
> openocd --version
> picotool -V
> ```

## Defaults inside the image
- `PICO_SDK_PATH=/opt/pico-sdk`
- `PICO_EXTRAS_PATH=/opt/pico-extras`
- `PICO_TOOLCHAIN_PATH=/usr`  *(Alpine-native toolchain lives in `/usr/bin`)*
- `CMAKE_C_COMPILER_LAUNCHER=ccache`
- `CMAKE_CXX_COMPILER_LAUNCHER=ccache`
- Non-root user `builder` (UID/GID configurable at build time)
- `WORKDIR=/work`

## Usage

### Quick start (interactive shell)
```bash
docker run --rm -it   --privileged -v /dev/bus/usb:/dev/bus/usb   -v "$(pwd)":/work -w /work   wischner/gcc-arm-none-eabi-rpi-pico:latest bash
```

### Recommended: match host ownership (so artifacts aren’t root-owned)
```bash
docker run --rm -it   --user $(id -u):$(id -g)   --privileged -v /dev/bus/usb:/dev/bus/usb   -v "$(pwd)":/work -w /work   wischner/gcc-arm-none-eabi-rpi-pico:latest bash
```

### (Optional) use a different SDK at runtime
```bash
docker run --rm -it   -e PICO_SDK_PATH=/work/lib/pico-sdk   -v "$HOME/pico-sdk":/work/lib/pico-sdk   -v "$(pwd)":/work -w /work   wischner/gcc-arm-none-eabi-rpi-pico:latest bash
```

## Build a Pico project
```bash
cmake -S . -B build -DPICO_SDK_PATH="${PICO_SDK_PATH}" -DPICO_BOARD=pico_w
cmake --build build -j
```

> `PICO_TOOLCHAIN_PATH` is already set to `/usr`, so you don’t need to pass it to CMake.

## Flash & debug

### SWD via OpenOCD + GDB
```bash
# Terminal 1
openocd -f interface/picoprobe.cfg -f target/rp2040.cfg
```

```bash
# Terminal 2
arm-none-eabi-gdb build/your.elf
(gdb) target remote localhost:3333
(gdb) monitor reset init
(gdb) load
(gdb) continue
```

### BOOTSEL via picotool
```bash
# Put the Pico into BOOTSEL (USB mass storage) mode first
picotool info -a
picotool load build/your.uf2 -f
```

### Convert ELF → UF2 (modern flow, replaces legacy elf2uf2)
```bash
picotool uf2 convert build/your.elf -o build/your.uf2
```

## Build-time arguments
Override with `--build-arg` as needed:
- `IMG_VERSION` (default: `1.0.0`)
- `UID` / `GID` (default: `1000` / `1000`)
- `PICO_SDK_REF` (default: `2.1.0`) — SDK tag/branch/commit (required by picotool ≥ 2.1.0)
- `PICO_EXTRAS_REF` (default: `2.1.0`) — extras tag/branch/commit (falls back to default branch if missing)

Example:
```bash
docker build   --build-arg PICO_SDK_REF=2.1.1   --build-arg PICO_EXTRAS_REF=2.1.1   -t wischner/gcc-arm-none-eabi-rpi-pico:2.1.1 .
```

## Notes
- For non-root USB access you need appropriate **udev rules on the host** (Pico/picoprobe).
- Image is Make/CMake-centric (no Ninja).
- `ccache` is pre-wired via CMake launcher env for faster rebuilds.
- If you override `PICO_SDK_PATH` at runtime and depend on extras, also set `PICO_EXTRAS_PATH`.

## Support and contributions
For bug reports, feature requests, or questions, please use the issue tracker:  
<https://github.com/wischner/docker-toolchains/issues>