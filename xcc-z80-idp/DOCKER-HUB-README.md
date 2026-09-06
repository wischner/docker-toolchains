# XCC Z80 for Iskra Delta Partner

**Support:** [wischner.co.uk/support](https://wischner.co.uk/support)

`wischner/xcc-z80-idp` is a Linux x86-64 development image for the Iskra
Delta Partner. It provides XCC Z80 2.5.0, the public Partner SDK, two graphics
library choices, the Squid serial protocol library, the PAKET package manager,
the complete Partner emulator and MCP runtime, a Partner-compatible XEMU memory
map, Snatch, and cpmdisk.

CP/M 3 is the default target. The only other installed target is `emu`.

```bash
export IMAGE=wischner/xcc-z80-idp:2.9.0
```

## Quick start

Create `hello.c`:

```c
#include <stdio.h>

int main(void)
{
    puts("Hello from Iskra Delta Partner!");
    return 0;
}
```

Build a CP/M 3 COM file in the current directory:

```bash
docker run --rm --user "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work "$IMAGE" \
  xcc hello.c -o hello.com
```

Build and run an emulator binary:

```bash
docker run --rm --user "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work "$IMAGE" \
  xcc --platform=emu --oformat=binary hello.c -o hello.bin

docker run --rm --user "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work "$IMAGE" \
  xemu --run --quiet --emu-stdio \
    --load-bin hello.bin --origin 0 --pc 0
```

For an interactive development shell:

```bash
docker run --rm -it --user "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work "$IMAGE" bash
```

## Included software

| Component | Version or policy |
| --- | --- |
| XCC Z80 | 2.5.0 |
| XCC targets | `cpm3` (default) and `emu` |
| Build tools | GNU Make, CMake, and Git |
| IDP SDK | Latest `main` at image build time |
| Partner libgpx | 1.0.0 |
| idp-udev ugpx | Latest `main` at image build time |
| libsquid | Latest `main` at image build time |
| PAKET | Latest `main` at image build time, with a boot floppy |
| Snatch | 1.0.0, executable and plugins only |
| cpmdisk | 1.1.0, executable and runtime library only |
| Partner emulator and MCP | idp-emu 1.1.0 complete portable runtime |

The resolved idp-udev, idp-sdk and libsquid revisions are recorded under
`/opt/idp/share/metadata/`, and PAKET's own three source revisions under
`/opt/paket/share/metadata/`; they are not pinned in the image source.

## Partner SDK and graphics libraries

Headers and libraries are already on XCC's search paths. No extra `-I` or
`-L` options are needed.

| Component | Include | Link |
| --- | --- | --- |
| IDP SDK | `#include <partner/...>` | `-lsdk` |
| Full Partner graphics | `#include <libgpx.h>` | `-lgpx` |
| Micro graphics | `#include <ugpx.h>` | `-lugpx` |
| Squid serial protocol | `#include <squid/snet.h>` | `-lsquid` |

Examples:

```bash
xcc console-demo.c -lsdk -o console-demo.com
xcc graphics-demo.c -lgpx -o graphics-demo.com
xcc micro-graphics.c -lugpx -o micro-graphics.com
xcc desktop.c -lsdk -lgpx -o desktop.com
xcc serial-demo.c -lsquid -o serial-demo.com
```

`libgpx` and `ugpx` are alternatives. Never link `-lgpx` and `-lugpx` in the
same program; the `xcc` and `xld` wrappers reject this combination. The SDK
can be used with either one.

Only public SDK and ugpx headers are installed. There is no automatic SDK
initialization: applications call the initialization routines they need.

## PAKET

`PAKET.COM` is the Retro Vault package manager for the Partner. It carries the
Retro Vault protocol over Squid wire protocol 2 on a chosen Partner serial
port and streams downloads straight into a CP/M file. The image ships the
built executable and a ready-to-boot floppy image containing it:

```bash
cpmdisk add mydisk.img -u 0 "$PAKET_COM"

cp "$PAKET_DISK" ./paket-fd0.img
idp-mcp --model gdp --fd0 ./paket-fd0.img
```

`PAKET_COM` is `/opt/paket/bin/paket.com` and `PAKET_DISK` is
`/opt/paket/share/paket/fddb.img`.

## Partner MCP and full emulator

`idp-mcp` is the preferred Partner runtime for AI clients. It runs invisibly,
speaks newline-delimited MCP JSON-RPC over stdin/stdout, and exposes bounded
execution, stepping, registers, memory, I/O, breakpoints, keyboard input,
screen capture/text, recording, and media mounting.

```bash
idp-mcp --model gdp
idp-mcp --list-tools
```

The complete idp-emu runtime is installed at `/opt/idp-emu`, not just the MCP
binary. It includes `idp-emu`, `idp-mcp`, `partnerp`, `partnerg`, the Partner
CMOS seed, CRT and GDP ROMs, Partner P and G system hard-disk seeds, UI assets,
shared libraries, and upstream documentation. All four commands are on
`PATH`.

Copy a system disk seed to a writable mounted directory before attaching it
directly to MCP:

```bash
cp "$IDP_MCP_GDP_HDD_SEED" ./partner-g.img
idp-mcp --model gdp --hdd ./partner-g.img
```

## Targets and Partner memory banking

The `xcc` and `xld` wrappers select `--platform=cpm3` unless a platform is
given. They reject all platforms except `cpm3` and `emu`; the `none` platform
is not installed.

XEMU loads `/etc/xemu/partner.conf` by default. It models Partner RAM as:

- `0x0000-0xBFFF`: a 48 KiB switchable window over two banks.
- `0xC000-0xFFFF`: 16 KiB common RAM.
- `IN` or `OUT` at `0x88-0x8F`: select bank 1 (the startup bank).
- `IN` or `OUT` at `0x90-0x97`: select bank 2.

A local `./xemu.conf` or `xemu --config FILE` overrides the default. This is a
Partner-compatible memory map, not complete hardware or ROM emulation.

## Tool examples

All commands are on `PATH`.

Configure and build a CMake project, or use a conventional Makefile:

```bash
cmake -S . -B build
cmake --build build
make
git status
```

Compile, assemble, link, and archive:

```bash
xcc -c module.c -o module.rel
xas -g start.s -o start.rel
xld start.rel -o start.com
xar --mode=gnu rcs libmodule.a module.rel
```

Convert an object and optimize generated assembly:

```bash
xobjcopy -I rel -O elf module.rel module.o
xcc -S -Os hello.c -o hello.s
xopt -Os hello.s -o hello.optimized.s
```

Run XEMU or its `xgdb-z80` compatibility alias:

```bash
xemu --run --quiet --emu-stdio \
  --load-bin hello.bin --origin 0 --pc 0
xgdb-z80 --run --load-bin hello.bin --origin 0 --pc 0
```

Remote debugging uses two shells in the same container:

```bash
# Shell 1
xemu --listen 127.0.0.1:9000

# Shell 2
xgdb --exec debug-demo.xl --cdb debug-demo.cdb \
  --remote 127.0.0.1:9000
```

Convert a TrueType font to a PNG sheet with Snatch:

```bash
snatch --extractor ttf_extractor \
  --extractor-parameters "input=Retro.ttf,font_size=16" \
  --exporter png --exporter-parameters "output=font.png"
```

Create and populate a Partner CP/M disk image:

```bash
cpmdisk create partner.dsk fdd --label PARTNER --datestamp
cpmdisk add partner.dsk -u 0 hello.com
cpmdisk list partner.dsk -u 0
```

Use `COMMAND --help` for full options. Detailed XCC manuals are installed in
`/opt/x/share/doc`.

## Installed paths

```text
/opt/x/bin/              XCC commands
/opt/x/z80/include/      public Z80 target headers
/opt/x/z80/lib/          target libraries, startup files, and linker scripts
/opt/idp/include/        public SDK, libgpx, ugpx, and squid headers
/opt/idp/lib/            libsdk.a, libgpx.a, libugpx.a, and libsquid.a
/opt/idp/share/metadata/ resolved source versions
/opt/paket/              PAKET.COM, its boot floppy, licence, and docs
/opt/snatch/             Snatch executable and runtime plugins
/opt/cpmdisk/            cpmdisk executable and runtime library
/opt/idp-emu/            complete Partner emulator and MCP runtime tree
/usr/bin/snatch          Snatch command
/usr/bin/cpmdisk         cpmdisk command
/usr/local/bin/idp-emu   full graphical Partner emulator
/usr/local/bin/idp-mcp   invisible Partner MCP server
/usr/local/bin/partnerp  Partner P/CRT system profile
/usr/local/bin/partnerg  Partner G/GDP system profile
```

## Intentional exclusions

- SDK internal headers, SDK init object, SDK SDCC and CP/M libraries, and SDCC.
- idp-udev ulibc, usdcc, CRT, replacement headers, and internal files.
- Snatch and cpmdisk development headers.
- XCC host-development headers under `/opt/x/include`.
- Platforms other than `cpm3` and `emu`.

XCC's Z80 target headers and native CP/M 3 runtime remain installed.

## Sources and full inventory

- [Image source and CONTENT.md](https://github.com/wischner/docker-toolchains/tree/main/xcc-z80-idp)
- [XCC/XYZ](https://github.com/retro-vault/xyz)
- [Partner libgpx](https://github.com/retro-vault/libgpx)
- [idp-udev](https://github.com/iskra-delta/idp-udev)
- [IDP SDK](https://github.com/iskra-delta/idp-sdk)
- [libsquid](https://github.com/retro-plastics/libsquid)
- [squid-server](https://github.com/retro-plastics/squid-server)
- [PAKET](https://github.com/iskra-delta/paket)
- [Snatch](https://github.com/retro-vault/snatch)
- [cpmdisk](https://github.com/iskra-delta/cpmdisk)
- [idp-emu and idp-mcp](https://github.com/iskra-delta/idp-emu)

## CONTRIBUTE

Contributions are welcome. Please open an issue or pull request:
<https://github.com/wischner/docker-toolchains>
