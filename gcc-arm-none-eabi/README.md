# GCC ARM (arm-none-eabi) toolchain

This image is part of **Wischner Ltd. Toolchains**.

> **Pin your tags.** Use a versioned tag such as `:1.1.0` instead of `:latest` for repeatable builds.

## What it is

An Ubuntu 22.04 based **ARM bare-metal development environment** built around the `arm-none-eabi` GCC toolchain.
It is intended for general microcontroller development and includes the standard compiler, binutils, newlib, GDB, OpenOCD, and common build utilities.

This image is the generic ARM base image.
It does **not** include Raspberry Pi Pico SDK content or Pico-specific host tools such as `pioasm` and `picotool`.
Those live in `wischner/gcc-arm-none-eabi-rpi-pico`.

## Installed components

- **GCC / G++** for `arm-none-eabi`
- **binutils** for `arm-none-eabi`
- **newlib** and bare-metal C/C++ runtime libraries
- **gdb-multiarch**
- **OpenOCD**
- **CMake**, **Make**, **Ninja**, **pkg-config**
- **Git**
- **Python 3** with `pyserial` and `pyelftools`
- USB/debug helpers: `usbutils`, `libusb`, `hidapi`
- Common utilities: `bash`, `curl`, `wget`, `tar`, `xz`, `file`

## Paths and environment

- Toolchain binaries live in `/usr/bin`
- Compatibility symlinks are available in `/opt/arm-none-eabi/bin`
- `ARM_NONE_EABI_TOOLCHAIN_PATH=/usr`
- Default working directory: `/work`

## Using this image as your compiler

You do not need to enter the container permanently. Run the toolchain directly from the host and bind-mount your project into `/work`.

### Quick examples

```bash
# Interactive shell
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-arm-none-eabi:1.1.0 \
  bash

# Compile a simple Cortex-M program
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-arm-none-eabi:1.1.0 \
  arm-none-eabi-gcc -mcpu=cortex-m3 -mthumb -Os \
    -ffunction-sections -fdata-sections \
    -Wl,--gc-sections -nostartfiles -specs=nosys.specs \
    -o hello.elf hello.c
```

## Debugging with OpenOCD and GDB

Adjust the interface and target scripts for your hardware:

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

## When to use the Pico image instead

Use `wischner/gcc-arm-none-eabi-rpi-pico` if you want:

- the Pico SDK preinstalled
- `pioasm`
- `picotool`
- `pico-extras`
- Raspberry Pi Pico and Pico W oriented defaults

## Build-time arguments

- `IMG_VERSION`

Example:

```bash
docker build \
  --build-arg IMG_VERSION=1.1.0 \
  -t wischner/gcc-arm-none-eabi:1.1.0 .
```

## Support and contributions

For bug reports, feature requests, or questions, please use the issue tracker:
[https://github.com/wischner/docker-toolchains/issues](https://github.com/wischner/docker-toolchains/issues)
