# SDCC Z80 for Iskra Delta Partner

`wischner/sdcc-z80-idp` is a Docker image for **Iskra Delta Partner**
development with SDCC, CP/M disk tooling, Partner-specific runtime libraries,
and the complete Partner emulator/MCP package.

It extends the generic Z80 toolchain with Partner-oriented headers, merged runtime libraries, disk image tooling, and the `ugpx` graphics library.

## What is included

- everything from `wischner/sdcc-z80`
- Partner SDK headers installed into the SDCC include paths
- merged `z80.lib` built from Partner SDK libraries
- normalized `crt0.rel`
- standalone `ugpx.lib` and `gpx/ugpx.h`
- `cpmdisk`
- `snatch`
- idp-emu 1.0.0: `idp-emu`, `idp-mcp`, `partnerp`, and `partnerg`
- Partner CMOS seed, CRT/GDP ROMs, P/G system disks, UI assets, shared
  libraries, and emulator documentation under `/opt/idp-emu`

## What this image is for

- Iskra Delta Partner application development
- CP/M disk image creation for Partner media
- projects that need Partner SDK headers and libraries preinstalled
- graphics-oriented Partner software that uses `ugpx`
- AI-controlled compile/run/debug workflows through Partner MCP

## Sample application

If you want a ready-made project that shows how to use this image, see:

- [`iskra-delta/idp-app`](https://github.com/iskra-delta/idp-app)

## Quick start

Compile a program:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:latest \
  sdcc -o hello.ihx hello.c
```

Compile with `ugpx`:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:latest \
  sdcc -o demo.ihx demo.c -l ugpx
```

Create a Partner disk image:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:latest \
  cpmdisk create partner-floppy.img idpfdd --label PARTNER --datestamp
```

Start the invisible Partner MCP server:

```bash
docker run --rm -i \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:latest \
  idp-mcp --model gdp
```

`idp-mcp` uses stdin/stdout for MCP JSON-RPC and exposes bounded execution,
registers, memory, I/O, breakpoints, keyboard control, screen capture/text,
recording, and media mounting. Use `idp-mcp --list-tools` for its schemas.

The image retains the full `/opt/idp-emu` runtime tree: graphical emulator,
MCP server, model launchers, `partner_cmos.bin`, both ROMs, both system-disk
seeds, assets, shared libraries, and docs. Copy a disk seed into `/work` before
attaching it directly to MCP so the guest writes to the copy.

## Environment

- `SNATCH_PLUGIN_DIR=/opt/snatch/plugins`
- `IDP_EMU_ROOT=/opt/idp-emu`
- `IDP_MCP_ROOT=/opt/idp-emu`
- `IDP_MCP_CRT_ROM=/opt/idp-emu/roms/partner_crt.rom`
- `IDP_MCP_GDP_ROM=/opt/idp-emu/roms/partner_gdp.rom`
- `IDP_MCP_CRT_HDD_SEED=/opt/idp-emu/disks/hdd-partner-p-system.img`
- `IDP_MCP_GDP_HDD_SEED=/opt/idp-emu/disks/hdd-partner-g-system.img`

## Support

Issues and pull requests are welcome:
<https://github.com/wischner/docker-toolchains>
