# GCC ARM (arm-none-eabi) toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is
ARM bare-metal GCC toolchain (`arm-none-eabi`) with GDB and OpenOCD for general embedded development. Supports compiling and debugging Cortex-M and other ARM microcontrollers.

## Installed components
- Alpine’s `arm-none-eabi` toolchain (GCC, G++, binutils, newlib)
- `arm-none-eabi-gcc`, `arm-none-eabi-g++`, `arm-none-eabi-as`, `arm-none-eabi-ld`
- `gdb-multiarch`
- [OpenOCD](https://openocd.org/) (mainline package)
- Build tools: `make`, `git`, `cmake`

> **Note on versions:** This image uses the versions provided by the Alpine 3.20 repositories.  
> Check at runtime with:
> ```bash
> arm-none-eabi-gcc --version
> gdb-multiarch --version
> openocd --version
> ```

## Usage
Run the container with your project mounted to `/work`:

```bash
docker run --rm -it -v "$(pwd)":/work wischner/gcc-arm-none-eabi:latest
```

Inside the container, compile for your target CPU:

```bash
arm-none-eabi-gcc -mcpu=cortex-m3 -mthumb -o app.elf app.c
```

## Debugging with OpenOCD + GDB
(Adjust interface/target scripts to your hardware.)

```bash
openocd -f interface/stlink.cfg -f target/stm32f1x.cfg
gdb-multiarch app.elf
```

## Notes for Raspberry Pi Pico / Pico W
- The toolchain binaries live in `/usr/bin`. If needed, point the Pico SDK to the toolchain with:
  ```bash
  -DPICO_TOOLCHAIN_PATH=/usr
  ```
- Set your SDK path as usual (either vendored in your repo or via `PICO_SDK_PATH`).

## Support and contributions

For bug reports, feature requests, or questions, please use the issue tracker:  
<https://github.com/wischner/docker-toolchains/issues>

Contributions are welcome. If you’d like to improve this image, feel free to open a pull request.