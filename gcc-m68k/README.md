# GCC m68k toolchain

This image is part of **Wischner Ltd. Toolchains**. It provides a current GNU
C/C++ cross-compiler for the bare-metal `m68k-elf` target.

## Installed components

- GNU Binutils 2.46.1
- GCC/G++ 16.1.0 with C++23 and experimental C++26 language support
- `m68k-elf-gcc`, `m68k-elf-g++`, `m68k-elf-cpp`
- the complete prefixed Binutils suite, including `as`, `ld`, `ar`, `nm`,
  `ranlib`, `objcopy`, `objdump`, `readelf`, `size`, `strings`, and `strip`
- CMake, GNU Make, Ninja, pkg-config, Git, and Python 3

## Important scope

This is a freestanding compiler. It includes `libgcc`, but deliberately does
not impose a target operating system, C library, C++ standard library, startup
files, or linker script. Modern C++ language features work, but facilities such
as `<vector>` need a target-specific libc/libstdc++ supplied by your project.

Use [`gcc-m68k-amiga`](../gcc-m68k-amiga) for AmigaOS applications; that image
has the Amiga ABI, NDK, runtimes, and full target libraries.

## Usage

```bash
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-m68k:1.2.0 \
  bash
```

Compile freestanding C and C++:

```bash
m68k-elf-gcc -ffreestanding -c startup.c -o startup.o
m68k-elf-g++ -std=c++23 -ffreestanding -fno-exceptions -fno-rtti \
  -c main.cpp -o main.o
m68k-elf-g++ -nostdlib -T target.ld startup.o main.o -lgcc -o app.elf
m68k-elf-objcopy -O binary app.elf app.bin
```

## Support

Issues and pull requests are welcome at
<https://github.com/wischner/docker-toolchains>.
