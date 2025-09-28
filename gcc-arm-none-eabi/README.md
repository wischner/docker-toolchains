# GCC ARM (arm-none-eabi) toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is
ARM bare-metal GCC toolchain (`arm-none-eabi`) with GDB and OpenOCD for general embedded development.  
Supports compiling and debugging Cortex-M and other ARM microcontrollers.

## Installed components
- [xPack GCC ARM Embedded](https://xpack.github.io/) 13.2.1
- `arm-none-eabi-gcc`, `arm-none-eabi-g++`, `arm-none-eabi-as`, `arm-none-eabi-ld`
- `gdb-multiarch` (multi-architecture GDB for cross-debugging)
- [OpenOCD](https://openocd.org/) (Raspberry Pi fork, with common ARM debug probes)
- Build tools: `make`, `git`, `cmake`

## Usage
Run the container with your project mounted to `/work`:

```bash
docker run --rm -it -v $(pwd):/work wischner/gcc-arm-none-eabi:latest
```

Inside the container, compile for your target CPU:

```bash
arm-none-eabi-gcc -mcpu=cortex-m3 -mthumb -o app.elf app.c
```

Debug with OpenOCD + GDB (adjust interface/target scripts to your hardware):

```bash
openocd -f interface/stlink.cfg -f target/stm32f1x.cfg
gdb-multiarch app.elf
```

This environment gives you a ready-to-use cross-compiler, debugger, and flashing tools for ARM-based microcontrollers.
