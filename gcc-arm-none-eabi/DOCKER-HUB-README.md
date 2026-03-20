# GCC ARM Bare-Metal Toolchain

`wischner/gcc-arm-none-eabi` is a ready-to-use Ubuntu 22.04 based Docker image for **ARM bare-metal development** with the `arm-none-eabi` toolchain.

It is designed as the general-purpose ARM base image in the Wischner toolchain family. Use it for Cortex-M and other microcontroller projects when you want a clean GNU embedded workflow with compiler, linker, debugger, and OpenOCD already installed.

## What is included

- `arm-none-eabi-gcc` and `arm-none-eabi-g++`
- `binutils-arm-none-eabi`
- newlib and bare-metal C/C++ runtime libraries
- `gdb-multiarch`
- `openocd`
- `cmake`, `make`, `ninja`, `pkg-config`
- `git`
- Python 3 with `pyserial` and `pyelftools`
- USB/debug helpers such as `usbutils`, `libusb`, and `hidapi`

## What this image is for

- general ARM bare-metal builds
- Cortex-M firmware development
- OpenOCD and GDB based debugging workflows
- C and C++ embedded projects that need a reproducible compiler environment

## Quick start

Interactive shell:

```bash
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-arm-none-eabi:latest \
  bash
```

Compile a simple Cortex-M program:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-arm-none-eabi:latest \
  arm-none-eabi-gcc -mcpu=cortex-m3 -mthumb -Os \
    -ffunction-sections -fdata-sections \
    -Wl,--gc-sections -nostartfiles -specs=nosys.specs \
    -o hello.elf hello.c
```

## Environment

- Working directory: `/work`
- Toolchain binaries: `/usr/bin`
- Compatibility symlinks: `/opt/arm-none-eabi/bin`
- `ARM_NONE_EABI_TOOLCHAIN_PATH=/usr`

## Support

Issues and pull requests are welcome:
<https://github.com/wischner/docker-toolchains>
