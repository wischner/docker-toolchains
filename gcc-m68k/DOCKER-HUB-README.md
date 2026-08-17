# GCC m68k bare-metal C/C++ toolchain

`wischner/gcc-m68k` provides a Dockerized, freestanding `m68k-elf`
cross-toolchain for Motorola 68000 development.

## Included

- GCC/G++ 16.1.0 with modern C++ language support
- GNU Binutils 2.46.1 (`as`, `ld`, `ar`, `nm`, `objcopy`, `objdump`,
  `readelf`, `ranlib`, `size`, `strings`, and `strip`)
- `libgcc`
- CMake, Make, Ninja, pkg-config, Git, and Python 3

This image intentionally has no target libc, libstdc++, startup files, or
linker script. Use it for freestanding systems, or supply those target pieces
from your project. For AmigaOS, use `wischner/gcc-m68k-amiga` instead.

```bash
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-m68k:1.2.0 \
  bash
```

```bash
m68k-elf-g++ -std=c++23 -ffreestanding -c main.cpp -o main.o
m68k-elf-objdump -d main.o
```

Support: <https://github.com/wischner/docker-toolchains>
