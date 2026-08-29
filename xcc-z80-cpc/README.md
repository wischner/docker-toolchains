# XCC Z80 – Amstrad CPC toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is

The medium-model [XCC Z80](../xcc-z80) toolchain with everything needed to
build, package, convert, compress, and run **Amstrad CPC** software, plus an
MCP server so an AI agent can drive a real CPC model directly.

In practice this gives you:

- `xcc`, `xas`, `xld`, `xar`, `xopt`, `xobjcopy`, `xgdb`, and `xemu` from the
  base image, with the `cpc-464`, `cpc-664`, and `cpc-6128` platforms staged
  on XCC's normal search path
- `xprog` for `.cdt` cassette images and AMSDOS `.dsk` disk images
- `libgpx` for the CPC, in both 640x200 and 320x200 display modes
- `amstrad-cpc-mcp` for headless emulation and AI-controlled runs
- `iDSK`, plus the LibDsk utilities, for disk image work
- `martine` for image, sprite, and screen conversion
- `salvador` (ZX0) and `apultra` (aPLib) for compression
- `snatch` for asset extraction and conversion

## Two execution models

The CPC support in this image comes in two deliberately separate forms. They
cannot be mixed in one link.

### Firmware-hosted (the default)

`cpc-464`, `cpc-664`, and `cpc-6128` link at `0x4000`, keep interrupts, use the
firmware Text VDU and keyboard jumpblocks, and return cleanly to BASIC. The 664
and 6128 targets add ROM-backed raw and stdio file operations through AMSDOS.
The 464 is cassette-only.

These are on XCC's normal search path, so they need nothing beyond
`--platform=`:

```bash
xcc -Os --platform=cpc-6128 --oformat=binary main.c -o app.bin
xprog --dsk app.bin --name APP.BIN -o app.dsk
```

### Bare-metal libgpx

`libgpx`'s CPC backend takes the machine over completely: `gpx_create()` pages
both ROMs out, so the firmware is gone and the firmware-hosted platforms above
cannot be used. It ships with its own startup file and lives under `/opt/cpc`,
deliberately off the default search path:

```bash
xcc -mz80 -std=c11 -Os -I"$LIBGPX_INCLUDE_DIR" -c main.c -o main.rel
xld --oformat=binary -b _CODE=0x8000 -nostartfiles \
    -o app.bin "$LIBGPX_CPC_CRT0" main.rel "$LIBGPX_LIB_DIR/libgpx.a"
```

One library serves both display modes. Pass `GPXM_CPC_640X200` (the default) or
`GPXM_CPC_320X200` to `gpx_create()`.

## Installed components

| Path | Contents |
|---|---|
| `/opt/x` | XCC prefix and Z80 target runtime, from the base image |
| `/opt/cpc` | libgpx CPC library, `crt0-cpc.rel`, header, licences, metadata |
| `/opt/amstrad-cpc-mcp` | Emulator/MCP server, firmware ROMs, CP/M disk |
| `/opt/idsk` | `iDSK` AMSDOS disk image tool |
| `/opt/martine` | `martine` image and sprite converter |
| `/opt/cpc-compress` | `salvador` and `apultra`, with their Z80 decrunchers |
| `/opt/snatch` | `snatch` and its plugins |

The LibDsk utilities (`dsktrans`, `dskid`, `dskform`, `dskdump`) come from the
distribution and are on `PATH`.

Environment variables: `CPC_ROOT`, `LIBGPX_INCLUDE_DIR`, `LIBGPX_LIB_DIR`,
`LIBGPX_CPC_CRT0`, `AMSTRAD_CPC_MCP_ROOT`, `AMSTRAD_CPC_MCP_ROMS`,
`MARTINE_ROOT`, `IDSK_ROOT`, `CPC_COMPRESS_ROOT`, `SNATCH_ROOT`, and
`SNATCH_PLUGIN_DIR`.

The image runs as a non-root user by default. If you want files created on a
bind mount to match your host UID/GID exactly, add `-u $(id -u):$(id -g)` to
`docker run`.

## Using this image

Build a 464 cassette program:

```bash
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80-cpc:latest \
  sh -c 'xcc -Os --platform=cpc-464 --oformat=binary main.c -o app.bin \
         && xprog --cdt app.bin --name APP -o app.cdt'
```

Insert `app.cdt` and enter `RUN"!APP"`.

Build a 6128 disk program and list the resulting image:

```bash
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80-cpc:latest \
  sh -c 'xcc -Os --platform=cpc-6128 --oformat=binary main.c -o app.bin \
         && xprog --dsk app.bin --name APP.BIN -o app.dsk \
         && iDSK app.dsk -l'
```

Convert a PNG to a CPC mode 1 screen:

```bash
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80-cpc:latest \
  martine -in picture.png -mode 1 -out .
```

Compress a binary with ZX0:

```bash
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80-cpc:latest \
  salvador app.bin app.bin.zx0
```

The matching Z80 decrunchers are in
`/opt/cpc-compress/share/asm/salvador` and
`/opt/cpc-compress/share/asm/apultra`.

Run the MCP server over stdio:

```bash
docker run --rm -i \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80-cpc:latest \
  amstrad-cpc-mcp
```

## Upstream sources

Pinned versions and moving refs live in [`build.args`](./build.args). Target
libraries and their sources are listed in
[`libraries.manifest`](./libraries.manifest); the exact commit used for each
moving ref is recorded under `/opt/cpc/share/metadata` and in the `.version`
file inside each tool's `/opt` prefix.

`IMG_VERSION` and the `BASE_IMAGE` tag are deliberately kept identical so the
image tag states which base toolchain image it was built on. `XYZ_VERSION`
names the installed compiler release and moves independently.

The CPC firmware ROMs are the freely redistributable English images fetched and
checksummed by `amstrad-cpc-mcp`'s own `fetch-roms.sh` during the build.
