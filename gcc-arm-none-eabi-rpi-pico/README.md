# GCC ARM for Raspberry Pi Pico / Pico W

This image is part of **Wischner Ltd. Toolchains** and extends `wischner/gcc-arm-none-eabi`.

> **Pin your tags.** Use versioned tags such as `:1.1.0` for both the base image and the Pico image to keep builds reproducible.

## What it is

An Ubuntu-based **Raspberry Pi Pico and Pico W development environment** built on top of the generic `arm-none-eabi` toolchain image.
It adds the Pico SDK, pico-extras, `pioasm`, `picotool`, Python helpers, and ccache for RP2040 workflows.

## Installed components

- Everything from `wischner/gcc-arm-none-eabi`
- **Pico SDK** installed at `/opt/pico-sdk`
- **pico-extras** installed at `/opt/pico-extras`
- **pioasm** built from the installed Pico SDK
- **picotool** built against the installed Pico SDK
- **ccache**
- **git-lfs**
- Additional Pico host dependencies such as `libftdi` and `libudev`

## Defaults inside the image

- `PICO_SDK_PATH=/opt/pico-sdk`
- `PICO_EXTRAS_PATH=/opt/pico-extras`
- `PICO_TOOLCHAIN_PATH=/usr`
- `CMAKE_C_COMPILER_LAUNCHER=ccache`
- `CMAKE_CXX_COMPILER_LAUNCHER=ccache`
- `CCACHE_DIR=/work/.ccache`
- Non-root user `builder`
- Default working directory: `/work`

## Using this image

### Quick start

```bash
docker run --rm -it \
  --privileged \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$PWD":/work -w /work \
  wischner/gcc-arm-none-eabi-rpi-pico:1.1.0 \
  bash
```

### Match host ownership

```bash
docker run --rm -it \
  --user $(id -u):$(id -g) \
  --privileged \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$PWD":/work -w /work \
  wischner/gcc-arm-none-eabi-rpi-pico:1.1.0 \
  bash
```

## Build a Pico project

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-arm-none-eabi-rpi-pico:1.1.0 \
  bash -c "cmake -S . -B build -DPICO_SDK_PATH=$PICO_SDK_PATH -DPICO_BOARD=pico_w && cmake --build build -j"
```

`PICO_TOOLCHAIN_PATH` is already set to `/usr`, so you usually do not need to pass it explicitly.

## Flashing and debugging

### SWD via OpenOCD and GDB

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
picotool info -a
picotool load build/your.uf2 -f
```

### Convert ELF to UF2

```bash
picotool uf2 convert build/your.elf -o build/your.uf2
```

## Build-time arguments

- `IMG_VERSION`
- `BASE_IMAGE`
- `UID`
- `GID`
- `PICO_SDK_REF`
- `PICO_EXTRAS_REF`

Example:

```bash
docker build \
  --build-arg BASE_IMAGE=wischner/gcc-arm-none-eabi:1.1.0 \
  --build-arg PICO_SDK_REF=2.1.0 \
  --build-arg PICO_EXTRAS_REF=2.1.0 \
  -t wischner/gcc-arm-none-eabi-rpi-pico:1.1.0 .
```

## Notes

- USB access still depends on appropriate host udev rules.
- `ccache` is pre-wired through the CMake launcher environment variables.
- If you override `PICO_SDK_PATH`, also override `PICO_EXTRAS_PATH` when your project uses pico-extras.

## Support and contributions

For bug reports, feature requests, or questions, please use the issue tracker:
[https://github.com/wischner/docker-toolchains/issues](https://github.com/wischner/docker-toolchains/issues)
