# SDCC Z80 for Iskra Delta Partner

`wischner/sdcc-z80-idp` is a Docker image for **Iskra Delta Partner** development with SDCC, CP/M disk tooling, and Partner-specific runtime libraries.

It extends the generic Z80 toolchain with Partner-oriented headers, merged runtime libraries, disk image tooling, and the `ugpx` graphics library.

## What is included

- everything from `wischner/sdcc-z80`
- Partner SDK headers installed into the SDCC include paths
- merged `z80.lib` built from Partner SDK libraries
- normalized `crt0.rel`
- standalone `ugpx.lib` and `gpx/ugpx.h`
- `cpmdisk`
- `snatch`

## What this image is for

- Iskra Delta Partner application development
- CP/M disk image creation for Partner media
- projects that need Partner SDK headers and libraries preinstalled
- graphics-oriented Partner software that uses `ugpx`

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

## Environment

- `SNATCH_PLUGIN_DIR=/opt/snatch/plugins`

## Support

Issues and pull requests are welcome:
<https://github.com/wischner/docker-toolchains>
