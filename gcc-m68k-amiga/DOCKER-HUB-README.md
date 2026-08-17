# GCC m68k AmigaOS

`wischner/gcc-m68k-amiga` is a complete, standalone `m68k-amigaos`
cross-development image built from the AmigaPorts toolchain.

It contains GCC/G++ 16.1 with modern C++ and libstdc++, the compatible
AmigaPorts Binutils 2.39 suite, GDB, gprof, FD/SFD generation tools, vasm,
IRA, NDK 3.2 and Kickstart 1.3 headers, newlib, libnix, clib2, ixemul headers,
pthreads, and all optional SDKs exposed by the upstream build. CMake, Make,
Ninja, pkg-config, Git, Python 3, and LHA are included for normal build and
packaging workflows.

The image also includes the standard host-side workflow around the compiler:
`amitools`/`vamos` for ADF, HDF, RDB, ROM, hunk, filesystem, and API-level
testing; `amigeconv`, Netpbm, and ImageMagick for bitplanes, sprites, palettes,
and ILBM graphics; SoX for 8SVX audio; and Shrinkler for executable/data
compression. Meson, ccache, ZIP, and common build utilities are available too.

This image is separate from `wischner/gcc-m68k`: the generic `m68k-elf` and
AmigaOS toolchains use different compiler builds, ABIs, runtimes, and output
formats.

```bash
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-m68k-amiga:1.1.0 \
  bash
```

```bash
m68k-amigaos-gcc -Os hello.c -o hello
m68k-amigaos-g++ -std=c++23 -Os hello.cpp -o hello-cpp
```

```bash
# Assets and an ADF image
amigeconv -f bitplane -l -d 5 art.png art.bpl
sox sample.wav -r 11025 -c 1 -b 8 sample.8svx
xdftool demo.adf create + format DEMO + write hello-cpp hello-cpp
Shrinkler -3 hello-cpp hello-cpp.shrunk
```

An included CMake toolchain file is available at
`/opt/amiga/share/cmake/m68k-amigaos.cmake` and through the
`CMAKE_TOOLCHAIN_FILE` environment variable.

See the repository README for runtime selection and CPU flags:
<https://github.com/wischner/docker-toolchains/tree/main/gcc-m68k-amiga>

Kickstart ROMs and Workbench media are not included. Use licensed media with a
real Amiga or an external full-system emulator for chipset-level testing.
