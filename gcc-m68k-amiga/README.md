# GCC m68k AmigaOS toolchain

This is a standalone `m68k-amigaos` cross-development image built from
[AmigaPorts/m68k-amigaos-gcc](https://github.com/AmigaPorts/m68k-amigaos-gcc).
It does not inherit from or contain the generic `m68k-elf` image because the
Amiga compiler uses its own patched GCC, ABI, headers, runtimes, and output
format.

## Compiler and core tools

- AmigaPorts GCC/G++ 16.1.1b: C, modern C++, and Objective-C
- the compatible AmigaPorts Binutils 2.39 suite
- `m68k-amigaos-gdb` and `m68k-amigaos-gprof`
- FD/SFD tools: `fd2sfd`, `fd2pragma`, and `sfdc`
- `vasmm68k_mot`, `vobjdump`, and the IRA reassembler
- AmigaOS NDK 3.2 plus the generated Kickstart 1.3 headers
- newlib, libnix, clib2, ixemul SDK headers, libgcc, libstdc++, libsupc++,
  libdebug, pthreads, and multilib variants
- every optional SDK exposed by the upstream `all-sdk` target
- `amitools` and `machine68k`: `vamos`, ADF/HDF, RDB, ROM, hunk, FD, and
  filesystem inspection tools
- `amigeconv` for PNG-to-bitplane, chunky, palette, copper-list, mask, and
  hardware-sprite conversion
- Netpbm and ImageMagick for IFF ILBM conversion and general image preparation
- SoX for Amiga IFF 8SVX sample conversion
- Shrinkler 4.7 plus its 68000 data-decompression sources
- CMake, Make, Ninja, Meson, ccache, pkg-config, Autotools, Git, Python 3,
  LHA, ZIP, and common command-line build utilities

The source orchestrator, GCC, and compatible Binutils commits are pinned in
`build.args`. Other AmigaPorts components are pinned to the
`AMIGA_GCC_SOURCE_DATE` snapshot.

Binutils is deliberately pinned to the AmigaPorts 2.39 line. In this pinned
source snapshot, the newer `amiga-2.46` line rejects byte branches while
building the base-relative newlib multilibs, so it cannot produce the complete
runtime matrix with GCC 16.1.

The additional Amiga host tools are also versioned or commit-pinned in
`build.args`. Their licenses, source revisions, Shrinkler decompression code,
and installed Python package versions are retained under
`/opt/amiga-host-tools/share`.

## Quick start

```bash
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-m68k-amiga:1.1.0 \
  bash
```

Build C or C++ directly:

```bash
m68k-amigaos-gcc -Os hello.c -o hello
m68k-amigaos-g++ -std=c++23 -Os hello.cpp -o hello-cpp
```

The default runtime is newlib for Kickstart 2.0+. Select another runtime by
putting its option last on the link command:

```bash
# libnix for Kickstart 2.0+
m68k-amigaos-gcc app.c -o app -mcrt=nix20

# libnix and compatible headers for Kickstart 1.3
m68k-amigaos-gcc app.c -o app13 -mcrt=nix13

# clib2
m68k-amigaos-gcc app.c -o app-clib2 -mcrt=clib2

# ixemul (requires ixemul.library on the Amiga)
m68k-amigaos-gcc app.c -o app-ixemul -mcrt=ixemul
```

## CMake

The included toolchain file is also exported as `CMAKE_TOOLCHAIN_FILE`:

```bash
cmake -S . -B build-amiga \
  -DCMAKE_TOOLCHAIN_FILE="$CMAKE_TOOLCHAIN_FILE" \
  -DCMAKE_BUILD_TYPE=MinSizeRel
cmake --build build-amiga -j
```

## Disk images and headless checks

The `amitools` suite can create and inspect ADF/HDF images, RDB partitions,
Kickstart ROMs, Amiga filesystems, and hunk executables:

```bash
# Create an OFS-formatted 880 KiB ADF and add the program.
xdftool demo.adf create + format DEMO + write build/demo demo + list

# Inspect an executable or run a system-friendly CLI program at API level.
hunktool info build/demo
vamos build/demo
```

`vamos` is useful for quick command-line and CI checks, but it is not a custom
chipset emulator. Final graphics, timing, device, and hardware tests still need
a real Amiga or a full-system emulator such as FS-UAE, Amiberry, or WinUAE.
Kickstart ROMs and Workbench media are copyrighted and are not included.

## Graphics and audio assets

For data loaded directly by a game or demo, `amigeconv` emits raw bitplanes,
chunky pixels, palettes, masks, copper lists, and 16/32/64-pixel hardware
sprites from PNG input:

```bash
amigeconv -f bitplane -l -d 5 art.png art.bpl
amigeconv -f palette -p loadrgb32 -c 32 art.png art.pal
amigeconv -f sprite -w 16 -d 2 -t player.png player.spr
```

Netpbm produces standard IFF ILBM files, while ImageMagick handles resizing,
cropping, and palette reduction:

```bash
convert art.png -resize 320x256 -colors 32 ppm:- | \
  ppmtoilbm -ecs -fixplanes 5 > art.iff
ilbmtoppm art.iff | convert ppm:- art-roundtrip.png
```

SoX reads and writes Amiga IFF 8SVX audio:

```bash
sox sample.wav -r 11025 -c 1 -b 8 sample.8svx
```

## Compression

Shrinkler can compress complete Amiga executables or raw data. Its
`ShrinklerDecompress.S` source is installed below
`/opt/amiga-host-tools/share/shrinkler/decrunchers` for data-mode users:

```bash
Shrinkler -3 build/demo build/demo.shrunk
Shrinkler --data --header --bytes assets.bin assets.shr
```

## CPU selection

The compiler supports the classic 68000 through 68060 families. For example:

```bash
m68k-amigaos-gcc -m68000 -Os app.c -o app-a500
m68k-amigaos-gcc -m68020 -m68881 -Os app.c -o app-a1200-fpu
```

## SDK build switch

All upstream optional SDKs are installed by default. To build only the core
NDK and runtime suite, set `INSTALL_ALL_SDKS=0`:

```bash
docker build --build-arg INSTALL_ALL_SDKS=0 -t gcc-m68k-amiga \
  gcc-m68k-amiga
```

Some bundled components and third-party SDKs have their own redistribution or
use terms. Review `/usr/share/doc/amiga-toolchain` and the upstream component
licenses, plus `/opt/amiga-host-tools/share`, before redistributing the image.
