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
- [Fuse](https://github.com/speccytools/fuse) (with GDB server)
- [bin2tap](https://github.com/compilersoftware/bin2tap) (convert flat binaries to `.tap`)
- Convenience wrappers:
  - `ihx2bin` — convert `.ihx` → `.bin`
  - `ihx2tap` — convert `.ihx` → `.tap` (default load address `32768`)
- Build tools: `make`, `git`

## Sample Project

[ZX Spectrum Template App](https://github.com/retro-vault/zxspec48-app)

## Usage
Run the container with your project mounted into `/work`:

    docker run --rm -it -v "$(pwd):/work" wischner/sdcc-z80-zx-spectrum:latest

### Compile for RAM (BASIC loader, code at 0x8000)

    # Default crt0 handles data init, BSS zeroing, and heap setup
    sdcc --code-loc 0x8000 --no-std-crt0 -DSPECTRUM crt0.rel hello.c
    ihx2tap hello.ihx

### Compile for ROM (code in ROM at 0x0000, variables in RAM at 0x8000)

    # Custom crt0 must copy initialized data from ROM to RAM
    sdcc --code-loc 0x0000 --data-loc 0x8000 --no-std-crt0 -DSPECTRUM crt0.rel hello.c

## What you need to know

This image ships SDCC with its generic Z80 `crt0.rel` and `z80.lib`. There is
no Spectrum-specific runtime — you control the memory layout yourself.

### Code and data placement

The base `sdcc-z80` image defaults to `_CODE = 0x0100` (CP/M) and no `_DATA`
address (linker places it after `_CODE`). For the Spectrum you must override
these with `--code-loc`:

- **RAM target** (BASIC loader): `--code-loc 0x8000` — code loads above the
  BASIC area. Data follows automatically.
- **ROM target** (bare metal): `--code-loc 0x0000 --data-loc 0x8000` — code
  goes to ROM at address 0; variables must be placed in RAM via `--data-loc`.
  You also need `--no-std-crt0` and a custom `crt0.rel` that initializes
  hardware and copies initialized data from ROM to RAM.

### What the default crt0 does

SDCC's generic `crt0.rel` performs:
1. Stack pointer setup
2. Initialized data (`_DATA`) copy from the load image
3. `_BSS` segment zeroing
4. Heap initialization (for `malloc`/`free`)
5. Call to `_main`

This is enough for simple RAM-only programs. For ROM targets or anything that
needs custom hardware init (interrupts, bank switching, screen mode), supply
your own `crt0.rel` with `--no-std-crt0`.

### Standard library functions

**Work out of the box** (no platform code needed):
- String: `strlen`, `strcpy`, `strcmp`, `memcpy`, `memset`, ...
- Math: `abs`, `atoi`, integer and floating-point arithmetic
- Memory: `malloc`, `free`, `calloc`, `realloc` (heap set up by default crt0)
- Formatting: `sprintf`, `sscanf` (no I/O, just buffers)

**Require you to provide `putchar()`:**
- `printf`, `puts`, `putchar` — for output to the Spectrum screen, typically
  via `RST 0x10` (ROM print routine) or direct framebuffer writes.

**Require you to provide `getchar()`:**
- `scanf`, `gets`, `getchar` — for keyboard input, typically via the Spectrum
  ROM routine at address `0x15D4` (`KEY_SCAN`) or your own key handler.

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
      wischner/sdcc-z80-zx-spectrum:latest \
      fuse hello.tap

## ROMs
Sinclair ROMs are in `/usr/share/spectrum-roms`.

## Environment
- `FUSE_ROM_DIR` — ROM directory inside the container (default: `/usr/share/spectrum-roms`)

## Support and contributions

For bug reports, feature requests, or questions, please use the issue tracker:
[https://github.com/wischner/docker-toolchains/issues](https://github.com/wischner/docker-toolchains/issues)

Contributions are welcome. If you'd like to improve this image, feel free to open a pull request.

---

This toolchain targets bare-metal ZX Spectrum builds.
