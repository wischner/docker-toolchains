# SDCC Z80 for Iskra Delta Partner

`sdcc-z80-idp` is a Docker image for building software for the **Iskra Delta
Partner** with **SDCC Z80**, packaging files onto Partner-compatible CP/M
disks, and running it with the complete Partner emulator or its invisible MCP
server.

Current image version: `1.12.0`

## What the image contains

The image is based on `wischner/sdcc-z80:latest` and adds the Partner-specific pieces on top of it.

Included tools:

- `sdcc`, `sdasz80`, `sdar`, `sdobjcopy`
- `ucsim`
- `cpmdisk` 1.2.0
- `snatch`
- `idp-emu`, `idp-mcp`, `partnerp`, `partnerg`

Included runtime content:

- SDCC Z80 headers installed into `/opt/sdcc/share/sdcc/include`
- SDCC Z80 runtime library installed into `/opt/sdcc/share/sdcc/lib/z80/z80.lib`
- startup object installed as `/opt/sdcc/share/sdcc/lib/z80/crt0.rel`
- standalone graphics library installed as `/opt/sdcc/share/sdcc/lib/z80/ugpx.lib`
- `ugpx` header installed as `/opt/sdcc/share/sdcc/include/gpx/ugpx.h`

Extra application content:

- `snatch` installed in `/opt/snatch`
- `snatch` plugins installed in `/opt/snatch/plugins`
- `SNATCH_PLUGIN_DIR=/opt/snatch/plugins`
- complete idp-emu 1.3.0 runtime under `/opt/idp-emu`, including the CMOS
  seed, CRT/GDP ROMs, Partner P/G system hard-disk seeds, UI assets, shared
  libraries, and upstream documentation

## How the toolchain is arranged

This image does not just add a few extra files beside the stock SDCC installation. It replaces the default Z80 include and library directories with content assembled for the Iskra Delta Partner workflow.

During image build:

- the source tree of the latest `iskra-delta/idp-sdk` release is staged into
  `sdcc-z80-idp/libraries/idp-sdk/source` (since v1.1.0 the release archive
  itself contains only the XCC-built library)
- inside the image, upstream's own `make _build TOOLCHAIN=sdcc` builds
  `libsdcc-z80`, the Partner build of `libcpm3-z80` (`PLATFORM=partner`), and
  the SDCC `libsdk.lib`; the `libsdcc-z80`/`libcpm3-z80` commits it cloned are
  recorded in `/opt/libraries/idp-sdk/.libsdcc-z80.version` and
  `.libcpm3-z80.version`
- the resulting `include/` tree (libc plus `partner/`) replaces the SDCC Z80
  include directory
- the resulting `libsdcc-z80.lib`, `libcpm3-z80.lib`, and `libsdk.lib`
  archives are unpacked and merged into `z80.lib`
- the resulting `crt0cpm3-z80.rel` startup object is normalized to `crt0.rel`
- `ugpx` is fetched separately from the latest `iskra-delta/idp-udev` `main` revision
- the exact `idp-udev` commit is recorded in `libraries/ugpx/.version`
- `ugpx` is installed as its own standalone `ugpx.lib`, not merged into `z80.lib`

That means:

- plain SDCC programs can compile without manually adding Partner include paths
- Partner runtime pieces are already in the standard SDCC search paths
- `ugpx` is linked explicitly with `-l ugpx`
- `ugpx` headers are included with `#include <gpx/ugpx.h>`

## Included libraries

### Merged into `z80.lib`

These are built from the latest `iskra-delta/idp-sdk` release source with
SDCC during the image build:

- `libsdcc-z80.lib`
- `libcpm3-z80.lib` (Partner platform build)
- `libsdk.lib`

These provide the base Partner-targeted SDCC runtime and CP/M-oriented pieces used by normal builds.

### Installed separately

`ugpx` is synced from `iskra-delta/idp-udev` and installed separately:

- library: `/opt/sdcc/share/sdcc/lib/z80/ugpx.lib`
- header: `/opt/sdcc/share/sdcc/include/gpx/ugpx.h`

Use it like this:

```c
#include <gpx/ugpx.h>
```

```bash
sdcc -o demo.ihx demo.c -l ugpx
```

This layout is intentional so that a future `gpx.h` can coexist beside `ugpx.h` under the same `gpx/` include folder.

## Bundled tools

### `cpmdisk`

`cpmdisk` is built from the pinned GitHub release tag (`v1.2.0`, set by `CPMDISK_VERSION` in `build.args`). It is used to create and inspect Iskra Delta Partner-compatible CP/M disk images; 1.2.0 adds the `fdd:p` (Partner P, 154 tracks) and `fdd:g` (Partner G, the `fdd` default) floppy formats and fixes an extent bug.

Typical uses:

- create a floppy image
- add files to a user area
- inspect directory contents

### `snatch`

`snatch` is installed from the latest GitHub release into `/opt/snatch` and exposed on `PATH`.

Typical uses:

- inspect available options with `snatch --help`
- run font extraction/export pipelines
- use plugins from `/opt/snatch/plugins`

The image sets:

```bash
SNATCH_PLUGIN_DIR=/opt/snatch/plugins
```

### Partner emulator and MCP

[idp-emu](https://github.com/iskra-delta/idp-emu) 1.3.0 is built natively for
Alpine/musl. The full upstream runtime tree is installed, not only the MCP
binary:

```text
/opt/idp-emu/
  partner_cmos.bin
  bin/idp-emu
  bin/idp-mcp
  bin/partnerp
  bin/partnerg
  shared/
  roms/partner_crt.rom
  roms/partner_gdp.rom
  disks/hdd-partner-p-system.img
  disks/hdd-partner-g-system.img
  assets/fonts/Inter.ttf
  assets/icons/
  docs/
```

`idp-emu` is the graphical Partner P/CRT and Partner G/GDP emulator.
`partnerp` and `partnerg` start model-specific system profiles and create
per-user writable disk copies from the packaged seeds.

`idp-mcp` runs the same cycle-stepped hardware invisibly for AI clients. It
speaks newline-delimited MCP JSON-RPC over stdin/stdout and exposes bounded
execution, stepping and cycle measurement, registers, memory, I/O,
breakpoints, keyboard input, screen text/PNG capture, recording, and media
mounting.

```bash
idp-mcp --model gdp
idp-mcp --list-tools
```

To boot a system disk through MCP, copy its read-only seed to the mounted work
directory first:

```bash
cp "$IDP_MCP_GDP_HDD_SEED" ./partner-g.img
idp-mcp --model gdp --hdd ./partner-g.img
```

`IDP_EMU_ROOT` and `IDP_MCP_ROOT` both point to `/opt/idp-emu`; the
`IDP_MCP_CRT_ROM`, `IDP_MCP_GDP_ROM`, `IDP_MCP_CRT_HDD_SEED`, and
`IDP_MCP_GDP_HDD_SEED` variables expose the packaged machine resources.

## Using the image

### Interactive shell

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:1.12.0 \
  bash
```

### Compile a simple program

Example source:

```c
#include <stdio.h>

int main(void) {
    puts("Hello, Iskra Delta Partner!");
    return 0;
}
```

Compile:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:1.12.0 \
  sdcc -o hello.ihx hello.c
```

Convert to a CP/M `.com` file:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:1.12.0 \
  sdobjcopy -I ihex -O binary hello.ihx hello.com
```

### Compile with `ugpx`

Example:

```c
#include <gpx/ugpx.h>

int main(void) {
    ginit(RES_1024x256);
    gcls();
    gexit();
    return 0;
}
```

Compile and link:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:1.12.0 \
  sdcc -o demo.ihx demo.c -l ugpx
```

### Create a Partner disk image

Create an empty floppy image:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:1.12.0 \
  cpmdisk create partner-floppy.img idpfdd --label PARTNER --datestamp
```

Add a compiled file:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:1.12.0 \
  cpmdisk add partner-floppy.img -u 0 hello.com
```

Inspect the result:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:1.12.0 \
  cpmdisk info partner-floppy.img
```

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:1.12.0 \
  cpmdisk list partner-floppy.img -u 0
```

### Run `snatch`

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:1.12.0 \
  snatch --help
```

## Library bundle workflow

The library payload is prepared before the Docker build by `sdcc-z80-idp/Makefile.toolchain`.

Relevant files:

```text
sdcc-z80-idp/
├── Dockerfile
├── Makefile.toolchain
├── build.args
├── libraries.manifest
├── libraries/              # generated during prepare step
└── README.md
```

`libraries.manifest` format:

```text
# <github_repo> [release_tag_or_latest_or_main-latest]
iskra-delta/idp-sdk latest
iskra-delta/idp-udev main-latest
```

## Building the image

Build locally:

```bash
make build-sdcc-z80-idp
```

The build does this automatically:

- prepares `sdcc-z80-idp/libraries/`
- fetches the latest configured release bundles and branch revisions
- uses `idp-sdk` as the source of the merged runtime, startup object, and headers
- fetches the latest `ugpx` sources from `idp-udev` `main` and builds them with SDCC
- builds the Docker image

## License

This image contains software from multiple upstream projects. License terms are those of the included components.

- SDCC: GPL-2.0-or-later
- Alpine packages: various open source licenses
- bundled upstream libraries and tools: see their respective repositories and release artifacts
