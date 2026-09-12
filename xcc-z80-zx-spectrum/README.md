# XCC Z80 for ZX Spectrum

`xcc-z80-zx-spectrum` is a complete ZX Spectrum 48K development image based
on the medium-model [`xcc-z80`](../xcc-z80) toolchain. It compiles RAM-loaded
programs, replacement ROMs, and divIDE/esxDOS disk programs, packages TAP/TZX
files and esxDOS IDE images, provides native ZX libgpx and libsquid libraries,
and includes the Beepolix music tools, ZX Spectrum MCP emulator, snatch asset
pipeline, and hdfmonkey for FAT-formatted HDF disk images.

Current image version: `2.10.0`. XCC version: `2.5.1`.

## Complete image contents

### XCC 2.5.1 medium model

The complete X Compiler Suite is under `/opt/x`, with `/opt/x/bin` on `PATH`:

| Command | Purpose |
|---|---|
| `xcc` | C23 compiler driver; defaults to `zx-ram` in this image |
| `xas` | Z80 assembler with SDCC and GNU syntax modes |
| `xld` | Linker; defaults to `zx-ram` in this image |
| `xar` | Static-library archiver |
| `xobjcopy` | Object, archive, binary, Intel HEX, and ELF conversion |
| `xopt` | Z80 assembly optimizer |
| `xprog` | XL process/service packager, ZX TAP/TZX packager, and esxDOS FAT16 IDE image writer |
| `xgdb` | Source-level debugger |
| `xemu` | Z80 emulator and debugger remote target |
| `xgdb-z80` | Compatibility alias for `xemu` |

This is the requested **medium (`M`) model**. It includes C23, `float`, and
32-bit `long` support. To keep the runtime smaller, it omits `double`,
`long long`, and floating-point stdio support.

The image-specific `xcc` and `xld` commands in `/usr/local/bin` select
`--platform=zx-ram` automatically. They accept an explicit `--platform=zx-ram`,
`--platform=zx-rom`, `--platform=zx-esxdos`, or `--platform=zx-esxdos-rom` and
reject unrelated platforms.
The unwrapped compiler and linker remain available as `/opt/x/bin/xcc` and
`/opt/x/bin/xld`.

XCC target headers are in `/opt/x/z80/include`. This includes the standard C
headers, `sys.h`, `sys/stat.h`, `sys/types.h`, `yos.h`, CP/M 3 headers, and
the platform-specific `zx-ram/conio.h`, `zx-rom/conio.h`, and esxDOS
`sys/esxdos.h` headers. When a ZX platform is selected, `<conio.h>` resolves
to that platform's keyboard API.

The target runtime directory `/opt/x/z80/lib` contains:

```text
crt0.rel                 linker.ld                 libc.a
crt0.s                   linker.lk                 libfixed.a
crt0-none.rel            linker-none.ld            libruntime.a
crt0-none.s              linker-none.lk            libnone.a
crt0-cpm3.rel            linker-cpm3.ld            libcpm3.a
crt0-cpm3.s              linker-cpm3.lk
crt0-emu.rel             linker-emu.ld             libemu.a
crt0-emu.s               linker-emu.lk
crt0-zx-ram.rel          linker-zx-ram.ld          libzx-ram.a
crt0-zx-ram.s            linker-zx-ram.lk
crt0-zx-rom.rel          linker-zx-rom.ld          libzx-rom.a
crt0-zx-rom.s            linker-zx-rom.lk
crt0-zx-esxdos.rel       linker-zx-esxdos.ld       libzx-esxdos.a
crt0-zx-esxdos.s         linker-zx-esxdos.lk
crt0-zx-esxdos-rom.rel   linker-zx-esxdos-rom.ld   libzx-esxdos-rom.a
crt0-zx-esxdos-rom.s     linker-zx-esxdos-rom.lk
crt0-yos.rel             linker-yos.ld             libyos.a
crt0-yos.s               linker-yos.lk
libgpx.a                 libgpx.lib
libsquid.a               libsquid.lib
```

The inherited host SDK under `/opt/x/include` and `/opt/x/lib` contains the
headers and static libraries for `rsp`, `xbfd`, `xemu`, `xgdb`, `xopt`, and
`xz80`. Tool manuals are installed under `/opt/x/share/doc` for `xar`, `xas`,
`xcc`, `xemu`, `xgdb`, `xld`, `xobjcopy`, `xopt`, `xprog`, and ZX48 usage.
`/opt/xtools` remains a compatibility symlink to `/opt/x`.

### Native ZX Spectrum targets

Four XCC 2.5.1 platforms are ready to use:

- `zx-ram` is the default. It produces a program loaded at `0x5CCB`, above
  the standard 48K ROM system variables. The upper 4 KiB is reserved for the
  stack and the remaining post-image RAM becomes the libc heap.
- `zx-rom` produces an exact 16 KiB replacement ROM. Startup copies writable
  initialized data into RAM, clears BSS, initializes the console, and calls
  `main`.
- `zx-esxdos` produces a program loaded at `0x8000` for a normally booted 48K
  Spectrum with divIDE (or compatible) hardware running esxDOS 0.8.9. It adds
  POSIX-style `open`, `read`, `write`, `lseek`, `fsync`, `stat`, `unlink`,
  `rename`, `chdir`, `mkdir`, and `rmdir` backed by the resident firmware, so
  the ordinary libc `fopen`/`fread`/`fwrite` family works on FAT disks. Load
  it from BASIC with `CLEAR 32767`, `LOAD *"APP.BIN" CODE 32768`, and
  `RANDOMIZE USR 32768`.
- `zx-esxdos-rom` produces an exact 16 KiB replacement ROM with the same disk
  API. It boots from reset without the Sinclair ROM; only 48 bytes of disk-call
  gates run in RAM. Set `AutoBoot=0` in `SYS/CONFIG/ESXDOS.CFG`.

All four platforms provide startup code, a proportional bitmap console,
keyboard input and `<conio.h>` `kbhit()`, libc I/O hooks, heap setup, and
linker scripts. They target the 48K machine; 128K bank switching is not part
of these runtimes. The esxDOS firmware itself is not bundled; supply your own
distribution on the disk image.

### ZX Spectrum libgpx

The current `main` revision of
[retro-vault/libgpx](https://github.com/retro-vault/libgpx) is used. Its
hand-written `src/zx` backend and the shared `src/common` circle and polygon
modules are assembled with the image's XCC `xas` and archived with `xar`, so
the archive is the complete library that upstream's own build produces.

| Item | Canonical path | XCC search path |
|---|---|---|
| Public header | `/opt/zx-spectrum/include/libgpx.h` | `/opt/x/z80/include/libgpx.h` |
| Static library | `/opt/zx-spectrum/lib/libgpx.a` | `/opt/x/z80/lib/libgpx.a` |
| Compatibility name | `/opt/zx-spectrum/lib/libgpx.lib` | `/opt/x/z80/lib/libgpx.lib` |
| Licence | `/opt/zx-spectrum/share/licenses/libgpx/LICENSE` | — |

Include it with `#include <libgpx.h>` and link it with `-lgpx`; no extra `-I`
or `-L` option is required. It supplies the ZX implementations of lifecycle,
screen clearing, dimensions, pixels, lines with patterns, rectangles, boxes
with selectable edges, circles, polygons, text, bitmaps, sprites, stock
cursors, and built-in fonts.

### ZX Spectrum libsquid

The current `main` revision of
[retro-plastics/libsquid](https://github.com/retro-plastics/libsquid) is used.
libsquid is the Squid serial wire protocol: a link layer with framing, retries
and acknowledgements, plus a small multiplexed socket API on top of it. The
image ships the hand-written Z80 assembly backend, which is substantially
smaller than the equivalent C implementation.

It is built by libsquid's own `scripts/build-z80.sh`, which verifies that the
C header and the assembler include still agree with the compact `wire.def`
contract, links a real program against the archive it just produced, and
enforces the backend's code-size ceiling. `zx-ram` and `zx-rom` emit identical
objects, so one archive serves both targets.

| Item | Canonical path | XCC search path |
|---|---|---|
| Public headers | `/opt/zx-spectrum/include/squid/` | `/opt/x/z80/include/squid/` |
| Static library | `/opt/zx-spectrum/lib/libsquid.a` | `/opt/x/z80/lib/libsquid.a` |
| Compatibility name | `/opt/zx-spectrum/lib/libsquid.lib` | `/opt/x/z80/lib/libsquid.lib` |
| Build record | `/opt/zx-spectrum/share/metadata/libsquid.toolchain` | — |
| Documentation | `/opt/zx-spectrum/share/doc/libsquid/README.md` | — |

Include it with `#include <squid/snet.h>` and `#include <squid/socket.h>`, and
link it with `-lsquid`; no extra `-I` or `-L` option is required. `snet_init()`
takes a platform structure of `send_char`, `recv_char`, `get_tick`,
`mem_alloc`, and `mem_free` hooks, so the library stays independent of any
particular serial hardware.

### Beepolix

The latest `main` revision of
[retro-vault/beepolix](https://github.com/retro-vault/beepolix) is built in
release mode and installed under `/opt/beepolix`. These commands are linked
into `/usr/local/bin`:

| Command | Purpose |
|---|---|
| `beplay` | Audition MIDI, BBSong, MOD, and PT3 music through host audio |
| `becompile` | Compile music to Spectrum machine code, TAP, or relocatable assembly |
| `bescore` | Export music as PNG, SVG, MusicXML, or LilyPond notation |

Beepolix supports the Spectrum 48K beeper engines, Spectrum 128 AY output, and
its other documented targets. ALSA, Cairo, Fontconfig, and PNG runtime support
needed by its tools is installed in the image.

### ZX Spectrum MCP

The latest `main` revision of
[retro-vault/zx-spectrum-mcp](https://github.com/retro-vault/zx-spectrum-mcp)
is built as a static C++20 executable. `zx-spectrum-mcp` is available in
`/usr/local/bin`; its complete installation is under `/opt/zx-spectrum-mcp`.

It is a headless, cycle-accurate Spectrum 48K emulator controlled over MCP on
stdin/stdout. It provides program/snapshot/tape loading, execution and
breakpoints, memory/register/I/O access, keyboard input, screen text and PNG
capture, YUV4MPEG2 recording, TAP/TZX playback, and Interface 1 serial
emulation.

Installed read-only data and documentation:

```text
/opt/zx-spectrum-mcp/share/zx-spectrum-mcp/roms/48.rom
/opt/zx-spectrum-mcp/share/zx-spectrum-mcp/roms/if1-2.rom
/opt/zx-spectrum-mcp/share/doc/zx-spectrum-mcp/
```

The `ZX_SPECTRUM_MCP_ROM` environment variable names the installed 48K ROM.
The ROM files have their own copyright status separate from the emulator's
GPL licence; users and distributors must ensure they have the right to use or
redistribute them.

### Snatch

The latest `main` revision of
[retro-vault/snatch](https://github.com/retro-vault/snatch) is built in release
mode and installed under `/opt/snatch`. `snatch` is linked into
`/usr/local/bin`, and `SNATCH_PLUGIN_DIR` points at
`/opt/snatch/lib/snatch/plugins`.

The installation includes the command and all upstream extractor,
transformer, and exporter plugins. Snatch development headers and static
libraries are not copied into the runtime image. Installed plugins are:

```text
bitmap_font_transformer.so
dither_1bpp_transformer.so
dummy_exporter.so
fzx_transformer.so
gem_fnt_c_exporter.so
gem_fnt_exporter.so
gem_fnt_extractor.so
gem_font_transformer.so
gem_icn_c_exporter.so
gem_icn_exporter.so
gem_icn_extractor.so
gem_icn_transformer.so
gem_img_c_exporter.so
gem_img_exporter.so
gem_img_extractor.so
gem_img_transformer.so
image_extractor.so
image_passthrough_extractor.so
png_exporter.so
raw_bin_exporter.so
raw_c_exporter.so
sdcc_asm_bitmap_font_exporter.so
sdcc_asm_tiny_font_exporter.so
tiny_bmp_transformer.so
tiny_font_bin_extractor.so
tiny_font_transformer.so
ttf_extractor.so
```

### hdfmonkey

The `master` revision of
[gasman/hdfmonkey](https://github.com/gasman/hdfmonkey) is built from source
and installed under `/opt/hdfmonkey`, with `hdfmonkey` linked into
`/usr/local/bin`. It creates, formats, and edits the FAT12/16/32 filesystems
inside HDF disk images (and headerless raw IDE images) used by Spectrum IDE
interfaces such as divIDE, DivMMC, and +3e, and by emulators like Fuse. Its
commands are `clone`, `create`, `format`, `get`, `ls`, `mkdir`, `put`,
`rebuild`, and `rm`; `hdfmonkey help <command>` prints each interface.

Ready-made empty FAT16 volumes labelled `ESXDOS` are shipped gzip-compressed
under `HDFMONKEY_IMAGE_DIR`:

```text
/opt/hdfmonkey/share/hdfmonkey/images/blank-16m.hdf.gz
/opt/hdfmonkey/share/hdfmonkey/images/blank-32m.hdf.gz
/opt/hdfmonkey/share/hdfmonkey/images/blank-64m.hdf.gz
/opt/hdfmonkey/share/hdfmonkey/images/blank-128m.hdf.gz
```

Decompress one to get a working disk, then add your program and the esxDOS
`SYS`, `BIN`, and `TMP` directories from your own firmware distribution.
hdfmonkey also reads the raw 16 MiB images written by `xprog --esxdos`.

### Other runtime utilities

The Ubuntu 24.04 image also provides `python3`, `curl`, standard POSIX shell
utilities, and CA certificates. The default user is the non-root `ubuntu`
user, and the working directory is `/work`.

## Quick start

Mount a project and open a shell:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80-zx-spectrum:2.10.0 \
  bash
```

### Build a RAM program and TAP/TZX images

The wrapper selects `zx-ram`, so the explicit platform flag is optional:

```bash
xcc -Os --oformat=binary main.c -lgpx -o app.bin
xprog --tap app.bin -o app.tap --name APP
xprog --tzx app.bin -o app.tzx --name APP
```

Minimal libgpx source:

```c
#include <libgpx.h>

int main(void)
{
    gpx_t *gpx = gpx_create(GPXM_DEFAULT);
    gpx_draw_pixel(gpx, 10, 10, CO_FORE, BM_CPY, 0);
    for (;;) { }
}
```

### Link a Squid serial program

```bash
xcc -Os --oformat=binary main.c -lsquid -o app.bin
```

```c
#include <stdint.h>
#include <stdlib.h>
#include <squid/snet.h>
#include <squid/socket.h>

static int     put(uint8_t c) { /* write one byte to your UART */ (void)c; return 0; }
static int     get(void)      { /* read one byte, or -1 */ return -1; }
static uint8_t tick(void)     { /* free-running timebase */ return 0; }

int main(void)
{
    squid_platform_t plat;
    squid_timing_t tm;
    int fd;

    /* Assign the hooks inside a function: xcc does not emit a static
       initializer that takes the address of a static function. */
    plat.send_char = put;
    plat.recv_char = get;
    plat.get_tick  = tick;
    plat.mem_alloc = malloc;
    plat.mem_free  = free;

    tm.timeout_ticks = 6;
    tm.ack_delay_ticks = 2;
    tm.ping_ticks = 0;
    tm.max_retries = 3;
    tm.payload_bytes = 0;

    snet_init(&plat, &tm);
    fd = squid_open(32, 32);
    squid_connect(fd, 1);
    while (!snet_link_is_up())
        snet_burst();
    return 0;
}
```

### Build a replacement ROM

```bash
xcc -Os --platform=zx-rom --oformat=binary main.c -lgpx -o app.rom
test "$(wc -c < app.rom)" -eq 16384
```

### Build an esxDOS disk program and put it on a disk image

```bash
xcc -Os --platform=zx-esxdos --oformat=binary diskio.c -o DISKIO.BIN

# Quickest: a 16 MiB raw IDE image holding only DISKIO.BIN
xprog --esxdos DISKIO.BIN --name DISKIO.BIN -o diskio.ide
hdfmonkey ls diskio.ide

# Or start from a blank FAT16 HDF, add esxDOS's SYS/BIN/TMP and the program
gunzip -c "$HDFMONKEY_IMAGE_DIR/blank-32m.hdf.gz" > disk.hdf
hdfmonkey put disk.hdf esxdos089/SYS esxdos089/BIN esxdos089/TMP /
hdfmonkey put disk.hdf DISKIO.BIN /DISKIO.BIN
hdfmonkey ls disk.hdf
```

```c
#include <fcntl.h>
#include <unistd.h>

int main(void)
{
    int fd = open("HELLO.TXT", O_WRONLY | O_CREAT | O_TRUNC);
    if (fd < 0) return 1;
    write(fd, "hello\r\n", 7);
    close(fd);
    return 0;
}
```

`hdfmonkey create --fat16 disk.hdf 64M LABEL` makes a fresh volume of any
size; `--fat16` keeps volumes below 64 MB compatible with esxDOS.

### Compile music with Beepolix

```bash
becompile --format=midi \
  --target=spectrum --engine=tri \
  --output=build/song --tap song.mid
```

Use `beplay --help`, `becompile --help`, and `bescore --help` for the complete
interfaces. Host audio playback needs access to an audio device, commonly by
passing `--device /dev/snd` to `docker run`.

### Start ZX Spectrum MCP

```bash
zx-spectrum-mcp --rom "$ZX_SPECTRUM_MCP_ROM"
```

The command reads newline-delimited MCP JSON-RPC from stdin and reserves
stdout for protocol responses. Use `zx-spectrum-mcp --list-tools` to print its
tool schemas.

### Run snatch

The installed plugin directory is selected automatically:

```bash
snatch \
  --extractor-parameters "input=font.ttf,first_ascii=32,last_ascii=126,font_size=16" \
  --exporter png_exporter \
  --exporter-parameters "output=font.png,columns=16,rows=6"
```

## Installed paths and environment

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
| `HDFMONKEY_ROOT` | `/opt/hdfmonkey` |
| `HDFMONKEY_IMAGE_DIR` | `/opt/hdfmonkey/share/hdfmonkey/images` |
| `HOME` | `/home/ubuntu` |

`/usr/local/bin` and `/opt/x/bin` are on `PATH`. All added application
commands therefore use conventional command locations while their complete,
self-contained payloads remain under `/opt`.

## How latest upstream revisions are selected

XCC itself is pinned to the latest released tag, `v2.5.1`, so the compiler
version stays reproducible. The Docker image tag versions the image and moves
independently when its contents change. libgpx, libsquid, Beepolix, ZX
Spectrum MCP, and snatch intentionally follow their current `main` branches,
and hdfmonkey follows upstream `master`. Docker BuildKit remote Git `ADD`
instructions resolve those refs on every build and invalidate cached layers
when the upstream commit changes.

The exact commits included in a built image are recorded in:

```text
/opt/zx-spectrum/share/metadata/libgpx.version
/opt/zx-spectrum/share/metadata/libsquid.version
/opt/beepolix/.version
/opt/zx-spectrum-mcp/.version
/opt/snatch/.version
/opt/hdfmonkey/.version
```

Their source URLs are stored beside those files. Build refs can be overridden
through the corresponding entries in [`build.args`](./build.args).

## Licences

Component licences and upstream documentation are retained below each
component's `/opt` prefix. libgpx and snatch are GPL-2.0 projects; Beepolix,
ZX Spectrum MCP, and hdfmonkey are GPL-3.0 projects. libsquid ships no licence
file of its own; its upstream README is installed under
`/opt/zx-spectrum/share/doc/libsquid`. Vendored dependencies retain their own
licences as documented upstream.
