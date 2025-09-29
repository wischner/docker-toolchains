# ZX Spectrum toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is
A ready-to-use build and emulation environment for ZX Spectrum development.  
It extends the base `wischner/sdcc-z80` image with Spectrum-specific tools and the Fuse emulator.

## Installed components
- [SDCC](https://sdcc.sourceforge.net/) 4.5.0 (Z80-family targets only)
- `sdasz80` / `sdldz80` (assembler and linker)
- `uCsim` with `sz80` wrapper (Z80 simulator)
- `libspectrum` (snapshot/tape/disk formats)
- [Fuse](https://github.com/speccytools/fuse) (speccytools fork, SDL backend; optional GDB server)
- [bin2tap](https://github.com/compilersoftware/bin2tap) (convert flat binaries to `.tap`)
- Convenience wrappers:
  - `zx-sdcc` — run SDCC with `-mz80 -DSPECTRUM`
  - `ihx2bin` — convert `.ihx` → `.bin`
  - `ihx2tap` — convert `.ihx` → `.tap` (default load address `32768`)
  - `fuse-run` — run Fuse using ROMs mounted at `/opt/roms`
  - `fuse-gdb-run` — run Fuse with GDB server enabled (if supported)
- Build tools: `make`, `git`

## Usage
Run the container with your project mounted into `/work`:

    docker run --rm -it -v "$(pwd):/work" wischner/sdcc-z80-zx-spectrum:latest

Compile and package a simple program:

    zx-sdcc hello.c
    ihx2tap hello.ihx

### Allow X11 from Docker (Linux)
Before launching the emulator GUI from a Linux host using X11, allow local Docker containers to connect to your X server:

    xhost +SI:localuser:$(whoami)

> You can revoke later with `+SI:localuser:$(whoami)`.  
> As a broader (less strict) alternative: `xhost +local:`.

### Run in the emulator (X11/Wayland required on the host)

X11 example:

    docker run --rm -it \
      -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
      -v "$(pwd):/work" \
      -v /path/to/roms:/opt/roms \
      wischner/sdcc-z80-zx-spectrum:latest \
      fuse-run hello.tap

Wayland (XWayland) example (values depend on your compositor):

    docker run --rm -it \
      -e DISPLAY \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      -v "$(pwd):/work" \
      -v /path/to/roms:/opt/roms \
      wischner/sdcc-z80-zx-spectrum:latest \
      fuse-run hello.tap

## ROMs
The `FUSE_ROM_DIR` points to `/usr/share/spectrum-roms`.

## Debugging with GDB
If the included Fuse build provides a GDB server, you can publish a port and attach with `gdb`:

    docker run --rm -it -p 1337:1337 \
      -v "$(pwd):/work" \
      -v /path/to/roms:/opt/roms \
      wischner/sdcc-z80-zx-spectrum:latest \
      fuse-gdb-run hello.tap

Attach from the host:

    gdb-multiarch -ex "target remote :1337" hello.elf

## Environment
- `FUSE_ROM_DIR` — ROM directory inside the container (default: `/opt/roms`)
- `FUSE_GDB_PORT` — port used by `fuse-gdb-run` (default: `1337`)

## Support and contributions

For bug reports, feature requests, or questions, please use the issue tracker:  
[https://github.com/wischner/docker-toolchains/issues](https://github.com/wischner/docker-toolchains/issues)

Contributions are welcome. If you’d like to improve this image, feel free to open a pull request.

---

This toolchain targets bare-metal ZX Spectrum builds.  
It does not provide libraries or target-specific CRTs — supply your own startup/runtime as needed.

