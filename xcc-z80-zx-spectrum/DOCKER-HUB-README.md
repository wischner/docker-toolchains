# XCC Z80 for ZX Spectrum

Ubuntu 24.04 development image for the ZX Spectrum 48K. It combines the XCC
2.3.2 medium-model C23 toolchain with native RAM and ROM platforms, the ZX
backend of libgpx, Beepolix, ZX Spectrum MCP, and snatch.

## Everything installed

### XCC and the ZX runtime

`/opt/x/bin` is on `PATH` and contains:

- `xcc` — medium-model C23 compiler driver
- `xas` — Z80 assembler
- `xld` — linker
- `xar` — static-library archiver
- `xobjcopy` — object/archive/image converter
- `xopt` — Z80 optimizer
- `xprog` — XL and Spectrum TAP/TZX packager
- `xgdb` — debugger
- `xemu` — emulator/debug target
- `xgdb-z80` — compatibility alias for `xemu`

The medium model includes `float` and 32-bit `long`; it deliberately omits
`double`, `long long`, and floating-point stdio. `/usr/local/bin/xcc` and
`/usr/local/bin/xld` wrap the originals and default to `--platform=zx-ram`.
Pass `--platform=zx-rom` for a 16 KiB replacement ROM. The raw commands remain
available as `/opt/x/bin/xcc` and `/opt/x/bin/xld`.

Target headers and libraries live in `/opt/x/z80/include` and
`/opt/x/z80/lib`. The image includes generic, CP/M 3, emulator, ZX RAM, and ZX
ROM CRTs, libraries, and linker scripts, plus `libc.a`, `libfixed.a`, and
`libruntime.a`. The host SDK libraries for RSP, XBFD, XEMU, XGDB, XOPT, and
XZ80 remain under `/opt/x/lib`, and all X tool manuals are under
`/opt/x/share/doc`.

### libgpx

The latest `retro-vault/libgpx` `main` is assembled with XCC's `xas` and
archived with `xar`:

```text
/opt/x/z80/include/libgpx.h
/opt/x/z80/lib/libgpx.a
/opt/x/z80/lib/libgpx.lib
```

The canonical files are under `/opt/zx-spectrum`. Use `#include <libgpx.h>`
and link with `-lgpx`; no custom include or library path is needed. This is
the hand-written ZX backend with screen, drawing, text, bitmap, sprite, cursor,
and built-in-font support.

### Beepolix

The latest `retro-vault/beepolix` `main` is built in release mode under
`/opt/beepolix`, with conventional command links:

- `beplay` — audition MIDI, BBSong, MOD, and PT3 music
- `becompile` — compile Spectrum beeper/AY music to machine code, TAP, or
  relocatable assembly
- `bescore` — export PNG, SVG, MusicXML, and LilyPond scores

ALSA, Cairo, Fontconfig, and PNG runtime support is included.

### ZX Spectrum MCP

The latest `retro-vault/zx-spectrum-mcp` `main` is installed under
`/opt/zx-spectrum-mcp` and exposed as `zx-spectrum-mcp`. It is a headless,
cycle-accurate 48K emulator controlled through MCP. Its tools cover execution,
debugging, memory/register/I/O access, keyboard input, screen capture, video,
tape playback, and Interface 1 serial emulation.

The package includes its documentation plus `48.rom` and `if1-2.rom` under
`/opt/zx-spectrum-mcp/share/zx-spectrum-mcp/roms`. Those ROMs have copyright
status separate from the GPL emulator; check your right to use or redistribute
them. `ZX_SPECTRUM_MCP_ROM` points to the installed 48K ROM.

### Snatch

The latest `retro-vault/snatch` `main` is installed under `/opt/snatch` and
exposed as `snatch`. All upstream runtime plugins are included; development
headers and static libraries are not. The plugins cover TTF/images, dithering,
bitmap/tiny fonts, FZX, SDCC assembly, raw/PNG output, and GEM FNT/ICN/IMG conversion.
`SNATCH_PLUGIN_DIR=/opt/snatch/lib/snatch/plugins` is set automatically.

### Base utilities

The image also includes Python 3, curl, CA certificates, standard shell
utilities, and the runtime libraries needed by the host tools. It runs as the
non-root `ubuntu` user in `/work`.

## Build a RAM program with libgpx

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80-zx-spectrum:2.3.2 \
  sh -lc 'xcc -Os --oformat=binary main.c -lgpx -o app.bin && xprog --tap app.bin -o app.tap --name APP'
```

Create TZX as well:

```bash
xprog --tzx app.bin -o app.tzx --name APP
```

## Build a replacement ROM

```bash
xcc -Os --platform=zx-rom --oformat=binary main.c -lgpx -o app.rom
```

The output is exactly 16,384 bytes.

## Use Beepolix

```bash
becompile --format=midi --target=spectrum --engine=tri \
  --output=build/song --tap song.mid
```

Use `beplay --help`, `becompile --help`, and `bescore --help` for their full
interfaces. Pass the host audio device to Docker when using live playback.

## Start ZX Spectrum MCP

```bash
zx-spectrum-mcp --rom "$ZX_SPECTRUM_MCP_ROM"
```

The server reads MCP JSON-RPC from stdin and writes protocol responses to
stdout. `zx-spectrum-mcp --list-tools` prints its schemas.

## Use snatch

```bash
snatch \
  --extractor-parameters "input=font.ttf,first_ascii=32,last_ascii=126,font_size=16" \
  --exporter png_exporter \
  --exporter-parameters "output=font.png,columns=16,rows=6"
```

## Paths and environment

| Variable | Value |
|---|---|
| `XTOOLS_ROOT` | `/opt/x` |
| `ZX_SPECTRUM_ROOT` | `/opt/zx-spectrum` |
| `LIBGPX_INCLUDE_DIR` | `/opt/zx-spectrum/include` |
| `LIBGPX_LIB_DIR` | `/opt/zx-spectrum/lib` |
| `BEEPOLIX_ROOT` | `/opt/beepolix` |
| `ZX_SPECTRUM_MCP_ROOT` | `/opt/zx-spectrum-mcp` |
| `ZX_SPECTRUM_MCP_ROM` | `/opt/zx-spectrum-mcp/share/zx-spectrum-mcp/roms/48.rom` |
| `SNATCH_ROOT` | `/opt/snatch` |
| `SNATCH_PLUGIN_DIR` | `/opt/snatch/lib/snatch/plugins` |

`/usr/local/bin` and `/opt/x/bin` are both on `PATH`.

## Latest-source policy

XCC is pinned to the current release, `v2.3.2`, and uses the requested medium
model. libgpx, Beepolix, ZX Spectrum MCP, and snatch follow their latest `main`
commits on every build. BuildKit remote Git inputs invalidate their layers
when those branches advance. Exact resolved commits are recorded in:

```text
/opt/zx-spectrum/share/metadata/libgpx.version
/opt/beepolix/.version
/opt/zx-spectrum-mcp/.version
/opt/snatch/.version
```

Component source URLs, licences, and documentation are retained under their
respective `/opt` prefixes.
