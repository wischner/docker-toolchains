# SDCC Z80 Toolchain

`wischner/sdcc-z80` is a Docker image for **Z80 C development** with SDCC and the bundled Z80 simulator.

It is intended as a lean, reusable base for retro Z80 projects and for higher-level target-specific images in the Wischner toolchain family.

## What is included

- SDCC for Z80-family targets
- `sdasz80`
- `sdldz80`
- `uCsim` with the `sz80` wrapper
- `make`
- `git`

## What this image is for

- generic Z80 C development
- retrocomputing projects
- custom Z80 hardware
- CI builds for SDCC-based projects

## Quick start

Compile a source file:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/sdcc-z80:latest \
  sdcc --debug hello.c
```

Run it in the simulator:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/sdcc-z80:latest \
  sz80 hello.ihx
```

## Notes

- This image is the base for higher-level target images such as ZX Spectrum, CP/M 3, and Iskra Delta Partner.
- The bundled SDCC Z80 configuration is adjusted for more practical defaults:
  - `_CODE` defaults to `0x0100` instead of `0x0200`, which matches the standard CP/M program load address.
  - `_DATA` is no longer forced to `0x8000`; it now follows `_CODE` by default unless you override it with `--data-loc`.
  - You can still override both with standard SDCC flags such as `--code-loc <addr>` and `--data-loc <addr>`.
- Modern SDCC no longer ships `sdcdb`, so source-level GDB-style debugging is not currently part of this image.

## Related images

- `wischner/sdcc-z80-zx-spectrum`
- `wischner/sdcc-z80-cpm3`
- `wischner/sdcc-z80-idp`

## Support

Issues and pull requests are welcome:
<https://github.com/wischner/docker-toolchains>
