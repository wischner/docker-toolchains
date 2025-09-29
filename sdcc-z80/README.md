# SDCC Z80 toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is
SDCC Z80-only cross-compiler environment and the Z80 simulator. Intended for bare-metal development on retro Z80 systems (ZX Spectrum, MSX, custom boards).  

## Installed components
- [SDCC](https://sdcc.sourceforge.net/) 4.5.0 (Z80-family targets only)
- `sdasz80` / `sdldz80` (assembler and linker)
- `uCsim` with `sz80` wrapper (Z80 simulator)
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
  sdcc -mz80 --debug hello.c

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
  sdcc -mz80 --debug main.c drivers/video.c zxlib/*.c
```

### Graphical debugging with DDD (X11)

Modern SDCC releases no longer ship **`sdcdb`**, the GDB-style debugger that DDD uses. Because of this, there is **no GDB-compatible source-level debugger for Z80** in this image right now. DDD requires a GDB-like backend; the bundled **uCsim/`sz80`** simulator is **not** GDB-compatible, so DDD cannot drive it.

We’re actively working on a replacement (either a `.cdb` → GDB bridge or an equivalent debugger). 

**Thank you for your patience** while we build this.

## Support and contributions

For bug reports, feature requests, or questions, please use the issue tracker:  
[https://github.com/wischner/docker-toolchains/issues](https://github.com/wischner/docker-toolchains/issues)

Contributions are welcome. If you’d like to improve this image, feel free to open a pull request.
