# SDCC Z80 for CP/M 3

`wischner/sdcc-z80-cpm3` is a Docker image for building **CP/M 3 software** with **SDCC Z80**, packaging files onto CP/M disk images, and using a CP/M 3 oriented runtime that is already installed into the standard SDCC search paths.

It extends `wischner/sdcc-z80` with CP/M-specific runtime content and disk image tooling, so it is useful both as a compiler image and as a complete CP/M 3 packaging environment.

## What is included

- everything from `wischner/sdcc-z80`
- CP/M 3 oriented headers installed into `/opt/sdcc/share/sdcc/include`
- CP/M 3 oriented runtime libraries merged into `/opt/sdcc/share/sdcc/lib/z80/z80.lib`
- startup object installed as `/opt/sdcc/share/sdcc/lib/z80/crt0.rel`
- `cpmdisk`

## How the toolchain is arranged

This image does more than add a helper tool.

During image build, the default Z80 include and library directories are replaced with content assembled from the bundled CP/M 3 library releases. That means:

- plain SDCC programs can compile without adding extra CP/M include paths
- CP/M 3 runtime pieces are already in the standard SDCC search paths
- the startup object is already installed as `crt0.rel`

The goal is that normal SDCC usage stays simple, while the resulting binaries are built against CP/M 3 oriented runtime content.

The runtime content in this image is built from these upstream projects:

- [`retro-vault/libsdcc-z80`](https://github.com/retro-vault/libsdcc-z80)
- [`retro-vault/libcpm3-z80`](https://github.com/retro-vault/libcpm3-z80)

## What this image is for

- CP/M 3 application development
- CP/M disk image creation and inspection
- reproducible SDCC-based CP/M build pipelines
- workflows where you want compiler and disk tooling in the same container

## Sample application

If you want a ready-made project that shows how to use this image, see:

- [`retro-vault/cpm3-app`](https://github.com/retro-vault/cpm3-app)

## Included tooling

### SDCC toolchain

You get the standard Z80 SDCC tools from the base image, including:

- `sdcc`
- `sdasz80`
- `sdar`
- `sdobjcopy`
- `sz80`

The base image also includes the SDCC Z80 defaults that were adjusted for practical use:

- `_CODE` defaults to `0x0100`
- `_DATA` is no longer forced to `0x8000`
- both can still be overridden with `--code-loc` and `--data-loc`

### `cpmdisk`

`cpmdisk` is included so you can create and inspect CP/M disk images directly in the same environment where you compile your binaries.

Typical uses:

- create a floppy image
- add files to a user area
- inspect image metadata
- inspect directory contents

## Quick start

Interactive shell:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-cpm3:latest \
  bash
```

Compile a simple program:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-cpm3:latest \
  sdcc -o hello.ihx hello.c
```

Convert it to a `.com` file:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-cpm3:latest \
  sdobjcopy -I ihex -O binary hello.ihx hello.com
```

Create an empty CP/M 3 disk image:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-cpm3:latest \
  cpmdisk create cpm3-floppy.img idpfdd --label CPM3 --datestamp
```

Add the compiled program to the image:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-cpm3:latest \
  cpmdisk add cpm3-floppy.img -u 0 hello.com
```

Inspect the image:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-cpm3:latest \
  cpmdisk info cpm3-floppy.img
```

List files in user area 0:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-cpm3:latest \
  cpmdisk list cpm3-floppy.img -u 0
```

## Why use this image instead of the base Z80 image

Use `wischner/sdcc-z80-cpm3` when you want CP/M 3 specific runtime content and disk-image tooling already wired in.

Use `wischner/sdcc-z80` when you only want the generic SDCC Z80 compiler/simulator environment.

## Support

Issues and pull requests are welcome:
<https://github.com/wischner/docker-toolchains>
