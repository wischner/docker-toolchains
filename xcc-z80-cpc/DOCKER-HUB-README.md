# XCC Z80 for Amstrad CPC

**Support:** [wischner.co.uk/support](https://wischner.co.uk/support)

Ubuntu 24.04 development image for the Amstrad CPC. It combines the XCC 2.5.0
medium-model C23 toolchain with native CPC 464, 664, and 6128 platforms, CDT
and DSK packaging, the CPC backend of libgpx, an emulator with an MCP server,
and the standard CPC disk, graphics, and compression tools.

## Quick start

```bash
export IMAGE=wischner/xcc-z80-cpc:2.7.0

# A 6128 disk program.
docker run --rm -v "$PWD":/work -w /work $IMAGE sh -c '
  xcc -Os --platform=cpc-6128 --oformat=binary main.c -o app.bin &&
  xprog --dsk app.bin --name APP.BIN -o app.dsk &&
  iDSK app.dsk -l'

# A 464 cassette program.
docker run --rm -v "$PWD":/work -w /work $IMAGE sh -c '
  xcc -Os --platform=cpc-464 --oformat=binary main.c -o app.bin &&
  xprog --cdt app.bin --name APP -o app.cdt'
```

Insert `app.cdt` and enter `RUN"!APP"`; the `!` suppresses the firmware's
physical PLAY prompt when an emulator has already started the virtual tape.

## Everything installed

### XCC and the CPC runtime

`/opt/x/bin` is on `PATH` and contains:

- `xcc` — medium-model C23 compiler driver
- `xas` — Z80 assembler
- `xld` — linker
- `xar` — static-library archiver
- `xobjcopy` — object/archive/image converter
- `xopt` — Z80 optimizer
- `xprog` — XL, Spectrum TAP/TZX, and CPC CDT/DSK packager
- `xgdb` — debugger
- `xemu` — emulator/debug target

The medium model includes `float` and 32-bit `long`; it deliberately omits
`double`, `long long`, and floating-point stdio.

Three CPC platforms are staged on XCC's normal search path:

| Platform | Media | Notes |
|---|---|---|
| `cpc-464` | Cassette | Firmware-hosted, no AMSDOS state |
| `cpc-664` | Disk | ROM-backed raw and stdio file operations |
| `cpc-6128` | Disk | ROM-backed raw and stdio file operations |

All three link at `0x4000`, keep interrupts, use the firmware Text VDU and
keyboard jumpblocks, manage a heap and private stack, and return cleanly to
BASIC. Their CRTs, archives, and linker scripts are in `/opt/x/z80/lib` as
`crt0-cpc-*.rel`, `libcpc-*.a`, and `linker-cpc-*.ld`.

### libgpx

The `retro-vault/libgpx` `v0.4.0` CPC backend is assembled with XCC's
`xas` and archived with `xar` under `/opt/cpc`:

```text
/opt/cpc/include/libgpx.h
/opt/cpc/lib/libgpx.a
/opt/cpc/lib/crt0-cpc.rel
```

**This is a bare-metal library.** `gpx_create()` pages both ROMs out, so the
firmware is gone and the firmware-hosted platforms above cannot be used with
it. It is deliberately kept off XCC's default search path and ships with its
own startup file:

```bash
xcc -mz80 -std=c11 -Os -I"$LIBGPX_INCLUDE_DIR" -c main.c -o main.rel
xld --oformat=binary -b _CODE=0x8000 -nostartfiles \
    -o app.bin "$LIBGPX_CPC_CRT0" main.rel "$LIBGPX_LIB_DIR/libgpx.a"
```

One library serves both display modes. Pass `GPXM_CPC_640X200` (the default)
or `GPXM_CPC_320X200` to `gpx_create()`; it programs the CRTC and the Gate
Array to match, and `gpx_width()` reports the geometry from then on. Screen,
drawing, text, bitmap, sprite, cursor, and built-in-font support are included.

### Amstrad CPC MCP

The latest `retro-vault/amstrad-cpc-mcp` `main` is installed under
`/opt/amstrad-cpc-mcp` and linked as `amstrad-cpc-mcp`. It is a headless
emulator with an MCP server, so an AI agent can load a CDT or DSK, boot a real
firmware model, drive the keyboard, and read back the screen.

CRTC types 0, 1, and 2 can be selected independently. The freely
redistributable English firmware ROMs are fetched and checksummed during the
build and installed under `/opt/amstrad-cpc-mcp/share/amstrad-cpc-mcp/roms`,
alongside a CP/M 2.2 system disk.

```bash
docker run --rm -i -v "$PWD":/work -w /work $IMAGE amstrad-cpc-mcp
```

### Disk tools

- `iDSK` — list, extract, insert, and inspect files on AMSDOS `.dsk` images,
  with BASIC detokenising and disassembly. Also linked as `idsk`.
- `dsktrans`, `dskid`, `dskform`, `dskdump` — the LibDsk utilities, for
  converting between DSK, EDSK, and raw formats and for identifying images.

### Graphics and assets

- `martine` — convert PNG and JPEG images to CPC screens, sprites, tiles, and
  palettes across all display modes, including overscan.
- `snatch` — asset extraction and conversion, with its plugins in
  `/opt/snatch/lib/snatch/plugins`.

### Compression

- `salvador` — ZX0 compressor
- `apultra` — aPLib compressor

The matching Z80 decrunchers ship alongside them, in
`/opt/cpc-compress/share/asm/salvador` and
`/opt/cpc-compress/share/asm/apultra`.

## Layout

```text
/opt/x/                  XCC prefix and Z80 target runtime
/opt/cpc/                libgpx CPC library, crt0, header, metadata
/opt/amstrad-cpc-mcp/    emulator, MCP server, firmware ROMs, CP/M disk
/opt/idsk/               iDSK
/opt/martine/            martine
/opt/cpc-compress/       salvador, apultra, and their Z80 decrunchers
/opt/snatch/             snatch and its plugins
/work                    default working directory
```

Environment variables: `CPC_ROOT`, `LIBGPX_INCLUDE_DIR`, `LIBGPX_LIB_DIR`,
`LIBGPX_CPC_CRT0`, `AMSTRAD_CPC_MCP_ROOT`, `AMSTRAD_CPC_MCP_ROMS`,
`MARTINE_ROOT`, `IDSK_ROOT`, `CPC_COMPRESS_ROOT`, `SNATCH_ROOT`, and
`SNATCH_PLUGIN_DIR`.

The image runs as a non-root user by default. Add `-u $(id -u):$(id -g)` to
`docker run` if you want files created on a bind mount to match your host
UID/GID exactly.

## Related images

- [`wischner/xcc-z80`](https://hub.docker.com/r/wischner/xcc-z80) — the base
  toolchain, which also carries the CPC platforms
- [`wischner/xcc-z80-zx-spectrum`](https://hub.docker.com/r/wischner/xcc-z80-zx-spectrum)
- [`wischner/xcc-z80-idp`](https://hub.docker.com/r/wischner/xcc-z80-idp)

## Upstream projects

- [xyz / X Compiler Suite](https://github.com/retro-vault/xyz)
- [libgpx](https://github.com/retro-vault/libgpx)
- [amstrad-cpc-mcp](https://github.com/retro-vault/amstrad-cpc-mcp)
- [snatch](https://github.com/retro-vault/snatch)
- [iDSK](https://github.com/cpcsdk/idsk)
- [Martine](https://github.com/jeromelesaux/martine)
- [salvador](https://github.com/emmanuel-marty/salvador)
- [apultra](https://github.com/emmanuel-marty/apultra)

Licensed GPL-2.0-or-later AND GPL-3.0-or-later; see the component licences
under each `/opt` prefix.
