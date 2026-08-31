# XCC Z80 for Iskra Delta Partner

`xcc-z80-idp` is the ready-to-use Iskra Delta Partner development image built
on [`xcc-z80`](../xcc-z80). It uses XCC's native CP/M 3 runtime by default and
adds the Partner SDK, full and micro graphics libraries, the Squid serial
protocol library, the PAKET package manager, disk/font host tools, and the
complete Partner emulator package with its headless MCP server.

Current image version: `2.8.0` (XCC Z80 `2.5.0`)

## Included components

- `wischner/xcc-z80:2.8.0`
- XCC's native CP/M 3 and emulator runtimes; no bare-metal `none` platform
- XEMU 2.5.0 with Partner-compatible RAM banking enabled by default
- GNU Make, CMake, and Git for project builds and source control
- [Partner libgpx](https://github.com/retro-vault/libgpx) `v0.4.0`, rebuilt
  with `xas`/`xar` as an independent `libgpx.a`
- Latest [idp-udev](https://github.com/iskra-delta/idp-udev) `main` at image
  build time: only μgpx, rebuilt with XCC as `libugpx.a`; μlibc and μsdcc
  are excluded
- Latest [idp-sdk](https://github.com/iskra-delta/idp-sdk) `main` at image
  build time, built with XCC
- Latest [libsquid](https://github.com/retro-plastics/libsquid) `main` at image
  build time: the hand-written Z80 backend of the Squid serial wire protocol,
  built for `cpm3` as `libsquid.a`
- Latest [PAKET](https://github.com/iskra-delta/paket) `main` at image build
  time: `PAKET.COM`, the Retro Vault package manager for the Partner, plus a
  ready-to-boot floppy image
- [snatch](https://github.com/retro-vault/snatch) `v1.0.0`, including its
  plugins
- [cpmdisk](https://github.com/iskra-delta/cpmdisk) `v1.1.0`
- [idp-emu](https://github.com/iskra-delta/idp-emu) `v1.1.0`: `idp-emu`,
  `idp-mcp`, `partnerp`, `partnerg`, CMOS seed, CRT/GDP ROMs, Partner P/G
  system disks, assets, runtime libraries, and documentation

The idp-sdk build deliberately contains only the XCC-built SDK archive and
public headers. It does **not** include `sdkinit.rel`, `libsdcc-z80.lib`,
`libcpm3-z80.lib`, or the SDCC CP/M startup object. Applications initialize
only the SDK subsystems they choose to use.

Only idp-udev's public `ugpx.h` and XCC-built μgpx archive are packaged. Its
root μlibc headers, μlibc library, μsdcc library, and CRT are excluded because
XCC supplies the C and CP/M 3 runtimes.

## Supported platforms

The image's `xcc` and `xld` commands add `--platform=cpm3` automatically. A
plain link therefore uses XCC's CP/M 3 startup code, `libcpm3.a`, and CP/M 3
linker script and produces a `.com`-style binary starting at `0x0100`.

Pass `--platform=emu` to compile or link for XEMU instead. The command wrappers
accept only `cpm3` and `emu`. The `none` platform payload and its equivalent
unsuffixed aliases are removed from the image.

## Headers and libraries

XCC and XLD discover the installed Partner content through their standard
target paths:

| Component | Header path | Library path | Link option |
|---|---|---|---|
| idp-sdk | `/opt/x/z80/include/partner/` | `/opt/x/z80/lib/libsdk.a` | `-lsdk` |
| Partner libgpx | `/opt/x/z80/include/libgpx.h` | `/opt/x/z80/lib/libgpx.a` | `-lgpx` |
| idp-udev μgpx | `/opt/x/z80/include/ugpx.h` | `/opt/x/z80/lib/libugpx.a` | `-lugpx` |
| libsquid | `/opt/x/z80/include/squid/` | `/opt/x/z80/lib/libsquid.a` | `-lsquid` |

Only idp-sdk's public `include/partner` tree is packaged; its internal
`lib/include/hw` build headers are deliberately excluded. The canonical public
headers and libraries live below `/opt/idp/include` and `/opt/idp/lib`; entries
in the XCC directories are symlinks. All four archives are GNU-format archives
created by XCC's `xar`. XCC's host-development headers under `/opt/x/include`
are also excluded; the required Z80 target headers remain under
`/opt/x/z80/include`.

Use the SDK library without any automatic SDK startup code:

```bash
xcc app.c -lsdk -o app.com
```

Use libgpx independently:

```bash
xcc graphics.c -lgpx -o graphics.com
```

Use the smaller μgpx alternative:

```bash
xcc micro-graphics.c -lugpx -o micro-graphics.com
```

`libgpx` and `libugpx` are alternatives and must never be linked into the same
program. The image's `xcc` and `xld` wrappers reject a link containing both
`-lgpx` and `-lugpx`.

Use the SDK with either graphics library, for example:

```bash
xcc desktop.c -lsdk -lgpx -o desktop.com
```

Talk the Squid serial protocol:

```bash
xcc serial.c -lsquid -o serial.com
```

No `-I`, `-L`, or `--platform=cpm3` option is required for these examples.

## Squid serial protocol

libsquid implements the Squid wire protocol: a link layer with framing,
retries and acknowledgements, plus a small multiplexed socket API above it.
The image ships the hand-written Z80 assembly backend, built for `cpm3` by
libsquid's own `scripts/build-z80.sh`. That script verifies that the C header
and the assembler include still agree with the compact `wire.def` contract,
links a real program against the archive it just produced, and enforces the
backend's code-size ceiling.

Include `<squid/snet.h>` and `<squid/socket.h>`. `snet_init()` takes a platform
structure of `send_char`, `recv_char`, `get_tick`, `mem_alloc` and `mem_free`
hooks, so the library carries no serial hardware assumptions of its own; the
Partner SIO layer is supplied by the calling program. Assign those hooks inside
a function — xcc does not emit a static initializer that takes the address of a
static function. The build record for the packaged archive is at
`/opt/idp/share/metadata/libsquid.toolchain`, and upstream documentation is at
`/opt/idp/share/doc/libsquid/README.md`.

## PAKET

`PAKET.COM` is the Retro Vault command-line package manager for the Partner.
It connects through a selected Partner serial port, carries the Retro Vault
protocol over Squid wire protocol 2 on channel 3, and streams downloads
straight into a CP/M file.

It is a finished CP/M 3 program rather than a library, and is installed
alongside a ready-to-boot floppy image:

| Item | Path | Variable |
|---|---|---|
| Executable | `/opt/paket/bin/paket.com` | `PAKET_COM` |
| Floppy image with `0:PAKET.COM` | `/opt/paket/share/paket/fddb.img` | `PAKET_DISK` |
| Licence | `/opt/paket/share/licenses/paket/LICENSE` | — |
| Documentation | `/opt/paket/share/doc/paket/README.md` | — |

Add it to a disk image of your own, or boot the packaged one:

```bash
cpmdisk add mydisk.img -u 0 "$PAKET_COM"

cp "$PAKET_DISK" ./paket-fd0.img
idp-mcp --model gdp --fd0 ./paket-fd0.img
```

Copy the packaged image before attaching it — the emulator writes to a mounted
floppy, and the shipped image is meant to stay pristine.

PAKET owns its small Partner SIO and RTC hardware layer and does not link
idp-sdk. It compiles libsquid's and squid-server's Z80 client sources directly
into the binary with a single socket, so it does not link the `libsquid.a`
archive above either; the commits of all three trees it was built from are
recorded under `/opt/paket/share/metadata`.

## Full Partner emulation and MCP

The complete idp-emu 1.1.0 portable runtime is installed under
`/opt/idp-emu`. `idp-emu` provides cycle-stepped Partner P/CRT and Partner
G/GDP hardware emulation. `partnerp` and `partnerg` start the corresponding
model with a per-user writable copy of its packaged system disk.

`idp-mcp` runs the same hardware model invisibly and exposes it to AI clients
as a stateful MCP server over stdin/stdout. Its tools cover bounded execution,
stepping and cycle measurement, registers, memory, I/O, breakpoints, keyboard
input, screen text and PNG capture, video recording, and live media mounting.

Start a ROM-only GDP MCP instance:

```bash
idp-mcp --model gdp
```

To boot from the packaged GDP system disk without modifying the read-only
seed, first copy it into the mounted work directory:

```bash
cp "$IDP_MCP_GDP_HDD_SEED" ./partner-g.img
idp-mcp --model gdp --hdd ./partner-g.img
```

`idp-mcp --list-tools` prints the MCP tool schemas. The server reserves stdout
for newline-delimited JSON-RPC and sends diagnostics to stderr, so an MCP client
can launch `/usr/local/bin/idp-mcp` directly inside a running container.

The full upstream runtime layout is retained, including `partner_cmos.bin`,
both original ROM images, both model-specific system hard disks, the Inter UI
font, icons, launchers, shared libraries, and command/packaging documentation.
The paths are rooted at `IDP_EMU_ROOT=/opt/idp-emu`; individual ROM and disk
seed paths are exported through the `IDP_MCP_*` variables.

## XEMU toolchain target

XEMU defaults to `/etc/xemu/partner.conf`, which models Partner's two 48 KiB
RAM banks at `0x0000–0xBFFF` and the 16 KiB common region at
`0xC000–0xFFFF`. Physical bank 1 is selected by any `IN` or `OUT` in
`0x88–0x8F`; physical bank 2 is selected by `0x90–0x97`. Bank 1 is active at
startup.

XEMU 2.5.0 is rebuilt with a narrow downstream patch because Partner selects
the bank from the port address and ignores the transferred byte. A local
`./xemu.conf` or explicit `xemu --config FILE` overrides the image default.
The default models Partner RAM banking, not the full peripheral set or ROM
overlay.

Build and run an emulator binary:

```bash
xcc --platform=emu --oformat=binary app.c -o app.bin
xemu --run --load-bin app.bin --origin 0x0000 --pc 0x0000
```

## Host and build tools

GNU Make, CMake, Git, `snatch`, and `cpmdisk` are directly available on `PATH`:

```bash
make --version
cmake --version
git --version
snatch --help
cpmdisk create partner.dsk fdd
cpmdisk add partner.dsk app.com
idp-mcp --version
```

The snatch executable and its runtime plugins are installed at `/opt/snatch`;
its development headers are not packaged. `SNATCH_PLUGIN_DIR` points to
`/opt/snatch/plugins`. The cpmdisk executable and the `libcpmdisk.so` shared
object it needs at runtime are installed at `/opt/cpmdisk`; cpmdisk development
headers are not packaged. The published host-tool assets currently make this
image an x86-64 image.

## Quick start

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80-idp:2.8.0 \
  xcc app.c -lsdk -o app.com
```

Open an interactive shell:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80-idp:2.8.0 \
  bash
```

Versioned component refs live in [`build.args`](./build.args), while
[`libraries.manifest`](./libraries.manifest) records the installed XCC target
libraries. idp-udev, idp-sdk, libsquid, squid-server and PAKET intentionally
follow their latest `main`; the exact commits resolved during a build are
recorded inside the image at:

```text
/opt/idp/share/metadata/idp-udev.version
/opt/idp/share/metadata/idp-sdk.version
/opt/idp/share/metadata/libsquid.version
/opt/paket/share/metadata/paket.version
/opt/paket/share/metadata/libsquid.version
/opt/paket/share/metadata/squid-server.version
```
