# SDCC Z80 toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is
SDCC Z80-only cross-compiler environment and the Z80 simulator. Intended for bare-metal development on retro Z80 systems (ZX Spectrum, MSX, custom boards).  

## Installed components
- [SDCC](https://sdcc.sourceforge.net/) 4.5.0 (Z80-family targets only)
- `sdasz80` / `sdldz80` (assembler and linker)
- `uCsim` with `sz80` wrapper (Z80 simulator)
- `xlink`, `xdbg`, and `xdbg-z80` from [retro-vault/xyz](https://github.com/retro-vault/xyz)
- `libxdbg*.a`, `libxdbgstub.a`, and the `xdbg` / `xdbgstub` public headers in `/usr/local`
- [DDD](https://www.gnu.org/software/ddd/) 3.4.x (graphical front-end for gdb/sdcdb)
- Build tools: `make`, `git`

## Using this image as your compiler (no interactive shell)

You don’t need to “enter” the container. Just run the tools **from the host** and bind-mount your project. All outputs go to your current directory because `/work` inside the container is bound to `$PWD` on the host.

### Quick examples

```bash
# Compile a single C file to Intel HEX (.ihx)
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/sdcc-z80:latest \
  sdcc --debug hello.c

# Run it in the Z80 simulator (uCsim)
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/sdcc-z80:latest \
  sz80 hello.ihx
```

### Multi-file build

```bash
# Compile multiple sources; sdcc will assemble/link and produce .ihx
docker run --rm -u $(id -u):$(id -g) -v "$PWD":/work -w /work \
  wischner/sdcc-z80:latest \
  sdcc --debug main.c drivers/video.c zxlib/*.c
```

### Graphical debugging with DDD (X11)

Modern SDCC releases no longer ship **`sdcdb`**, but this image now includes `xdbg` and `xdbg-z80` from `retro-vault/xyz`.

The most reliable workflow is running `xdbg` directly in a terminal. DDD can also be pointed at `xdbg` as a best-effort GDB-like frontend for common operations, but it is not a full GDB replacement yet.

The bundled **uCsim/`sz80`** simulator is still separate and is not driven by DDD directly.

## Changelog

### 1.5.0
- Updated the bundled `retro-vault/xyz` host tools from `v1.2.0` to `v1.3.0`.

### 1.3.0
- Updated the bundled `retro-vault/xyz` host tools from `v1.1.0` to `v1.2.0`.

### 1.2.0
- Added Alpine-native `retro-vault/xyz` host tools to the standard `/usr/local` paths:
  `xlink`, `xdbg`, `xdbg-z80`, `libxdbg*.a`, `libxdbgstub.a`, and the
  `xdbg` / `xdbgstub` headers.

### 1.1.0
- Patched SDCC default segment locations for Z80:
  - `_CODE`: changed from `0x0200` to `0x0100` (standard CP/M TPA address).
    Override with `--code-loc <addr>`.
  - `_DATA`: removed hardcoded `0x8000` default. The linker now places `_DATA`
    immediately after `_CODE` instead of wasting the address space in between.
    Override with `--data-loc <addr>`.

### 1.0.1
- Initial public release.

## Support and contributions

For bug reports, feature requests, or questions, please use the issue tracker:  
[https://github.com/wischner/docker-toolchains/issues](https://github.com/wischner/docker-toolchains/issues)

Contributions are welcome. If you’d like to improve this image, feel free to open a pull request.
