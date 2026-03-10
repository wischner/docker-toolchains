# SDCC Z80 for CP/M 3

`sdcc-z80-cpm3` is a Docker image for building **CP/M 3** software with **SDCC Z80**, packaging files onto CP/M disk images, and using a CP/M 3-oriented runtime bundled directly into the image.

Current image version: `1.0.0`

## What the image contains

The image is based on `wischner/sdcc-z80:latest` and adds CP/M-oriented pieces on top of it.

Included tools:

- `sdcc`, `sdasz80`, `sdar`, `sdobjcopy`
- `ucsim`
- `cpmdisk`

Included runtime content:

- SDCC Z80 headers installed into `/opt/sdcc/share/sdcc/include`
- SDCC Z80 runtime library installed into `/opt/sdcc/share/sdcc/lib/z80/z80.lib`
- startup object installed as `/opt/sdcc/share/sdcc/lib/z80/crt0.rel`

## How the toolchain is arranged

This image replaces the default Z80 include and library directories with content assembled from the bundled CP/M 3 library releases.

During image build:

- release bundles listed in `libraries.manifest` are downloaded into `sdcc-z80-cpm3/libraries/`
- their headers are copied into the SDCC include directory
- their `.lib` archives are unpacked and merged into `z80.lib`
- a `crt0*.rel` startup object is normalized to `crt0.rel`

That means:

- plain SDCC programs can compile without manually adding extra include paths
- the bundled runtime pieces are already in the standard SDCC search paths

## Included libraries

These are synced from GitHub releases listed in `libraries.manifest`:

- `retro-vault/libsdcc-z80`
- `retro-vault/libcpm3-z80`

These provide the base SDCC runtime and CP/M 3 pieces used by normal builds.

## Bundled tools

### `cpmdisk`

`cpmdisk` is installed from the latest GitHub release or a pinned tag at build time. It is used to create and inspect CP/M disk images.

Typical uses:

- create a floppy image
- add files to a user area
- inspect directory contents

## Using the image

### Interactive shell

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-cpm3:1.0.0 \
  bash
```

### Compile a simple program

Example source:

```c
#include <stdio.h>

int main(void) {
    puts("Hello, CP/M 3!");
    return 0;
}
```

Compile:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-cpm3:1.0.0 \
  sdcc -o hello.ihx hello.c
```

Convert to a CP/M `.com` file:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-cpm3:1.0.0 \
  sdobjcopy -I ihex -O binary hello.ihx hello.com
```

### Create a CP/M disk image

Create an empty floppy image:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-cpm3:1.0.0 \
  cpmdisk create cpm3-floppy.img idpfdd --label CPM3 --datestamp
```

Add a compiled file:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-cpm3:1.0.0 \
  cpmdisk add cpm3-floppy.img -u 0 hello.com
```

Inspect the result:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-cpm3:1.0.0 \
  cpmdisk info cpm3-floppy.img
```

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-cpm3:1.0.0 \
  cpmdisk list cpm3-floppy.img -u 0
```

## Library bundle workflow

The library payload is prepared before the Docker build by `sdcc-z80-cpm3/Makefile.toolchain`.

Relevant files:

```text
sdcc-z80-cpm3/
├── Dockerfile
├── Makefile.toolchain
├── build.args
├── libraries.manifest
├── libraries/              # generated during prepare step
└── README.md
```

`libraries.manifest` format:

```text
# <github_repo> [release_tag_or_latest]
retro-vault/libsdcc-z80 latest
retro-vault/libcpm3-z80 latest
```

## Building the image

Build locally:

```bash
make build-sdcc-z80-cpm3
```

The build does this automatically:

- prepares `sdcc-z80-cpm3/libraries/`
- fetches the latest configured release bundles
- builds the Docker image

## License

This image contains software from multiple upstream projects. License terms are those of the included components.

- SDCC: GPL-2.0-or-later
- Alpine packages: various open source licenses
- bundled upstream libraries and tools: see their respective repositories and release artifacts
