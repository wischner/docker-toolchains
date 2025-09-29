# GCC m68k toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is
GCC cross-compiler for Motorola 68000 (`m68k-elf`) with binutils, tuned for retro/embedded targets.  
Suitable for bare-metal projects (no OS libc), retrocomputing, and hobbyist systems such as Amiga, Atari ST, or Sega consoles.

## Installed components
- [GNU Binutils](https://www.gnu.org/software/binutils/) 2.42 (m68k target)
- [GCC](https://gcc.gnu.org/) 13.x (cross `m68k-elf`)
- `m68k-elf-gcc`, `m68k-elf-as`, `m68k-elf-ld`, `m68k-elf-objcopy`, `m68k-elf-objdump`
- Build tools: `make`, `git`

## Usage
Run the container with your sources mounted:

```bash
docker run --rm -it -v $(pwd):/work wischner/gcc-m68k:latest
```

Inside the container, compile:

```bash
m68k-elf-gcc -o hello.elf hello.c
m68k-elf-objcopy -O binary hello.elf hello.bin
```

Disassemble:

```bash
m68k-elf-objdump -d hello.elf
```

> Note: This toolchain does not include libc or startup files — you must supply your own startup code and linker script for your target.

## Support and contributions

For bug reports, feature requests, or questions, please use the issue tracker:  
[https://github.com/wischner/docker-toolchains/issues](https://github.com/wischner/docker-toolchains/issues)

Contributions are welcome. If you’d like to improve this image, feel free to open a pull request.