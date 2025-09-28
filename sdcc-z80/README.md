# SDCC Z80 toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is
SDCC Z80-only cross-compiler environment and the Z80 simulator.  
Intended for bare-metal development on retro Z80 systems (ZX Spectrum, MSX, custom boards).  

## Installed components
- [SDCC](https://sdcc.sourceforge.net/) 4.5.0 (Z80-family targets only)
- `sdasz80` / `sdldz80` (assembler and linker)
- `uCsim` with `sz80` wrapper (Z80 simulator)
- Build tools: `make`, `git`

## Usage
Run the container with your source tree mounted:

```bash
docker run --rm -it -v $(pwd):/work wischner/sdcc-z80:latest
```

Inside the container:

```bash
sdcc -mz80 hello.c
sz80 hello.ihx
```

> Note: This toolchain includes only the Z80 ports of SDCC. It does not provide CP/M libraries or target-specific CRT code — you supply your own startup and runtime as needed.  
> Available switches include `-mz80`, `-mz80n`, `-msm83`, `-mez80_z80`, etc.
