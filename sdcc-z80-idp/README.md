# SDCC Z80 for Iskra Delta Partner

`sdcc-z80-idp` is a Docker image for building software for the **Iskra Delta Partner** with **SDCC Z80**, packaging files onto Partner-compatible CP/M disks, and using the Partner-oriented runtime and graphics libraries bundled into the image.

Current image version: `1.2.0`

## What the image contains

The image is based on `wischner/sdcc-z80:latest` and adds the Partner-specific pieces on top of it.

Included tools:

- `sdcc`, `sdasz80`, `sdar`, `sdobjcopy`
- `ucsim`
- `cpmdisk`
- `snatch`

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

## How the toolchain is arranged

This image does not just add a few extra files beside the stock SDCC installation. It replaces the default Z80 include and library directories with content assembled for the Iskra Delta Partner workflow.

During image build:

- release bundles listed in `libraries.manifest` are downloaded into `sdcc-z80-idp/libraries/`
- their headers are copied into the SDCC include directory
- their `.lib` archives are unpacked and merged into `z80.lib`
- a `crt0*.rel` startup object is normalized to `crt0.rel`
- `ugpx` is fetched separately from `iskra-delta/idp-udev`
- `ugpx` is built as its own standalone `ugpx.lib`, not merged into `z80.lib`

That means:

- plain SDCC programs can compile without manually adding Partner include paths
- Partner runtime pieces are already in the standard SDCC search paths
- `ugpx` is linked explicitly with `-l ugpx`
- `ugpx` headers are included with `#include <gpx/ugpx.h>`

## Included libraries

### Merged into `z80.lib`

These are synced from GitHub releases listed in `libraries.manifest`:

- `retro-vault/libsdcc-z80`
- `retro-vault/libcpm3-z80`

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

`cpmdisk` is installed from the latest GitHub release or a pinned tag at build time. It is used to create and inspect Iskra Delta Partner-compatible CP/M disk images.

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

## Using the image

### Interactive shell

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:1.2.0 \
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
  wischner/sdcc-z80-idp:1.2.0 \
  sdcc -o hello.ihx hello.c
```

Convert to a CP/M `.com` file:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:1.2.0 \
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
  wischner/sdcc-z80-idp:1.2.0 \
  sdcc -o demo.ihx demo.c -l ugpx
```

### Create a Partner disk image

Create an empty floppy image:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:1.2.0 \
  cpmdisk create partner-floppy.img idpfdd --label PARTNER --datestamp
```

Add a compiled file:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:1.2.0 \
  cpmdisk add partner-floppy.img -u 0 hello.com
```

Inspect the result:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:1.2.0 \
  cpmdisk info partner-floppy.img
```

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:1.2.0 \
  cpmdisk list partner-floppy.img -u 0
```

### Run `snatch`

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:1.2.0 \
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
# <github_repo> [release_tag_or_latest]
retro-vault/libsdcc-z80 latest
retro-vault/libcpm3-z80 latest
iskra-delta/idp-udev latest
```

## Building the image

Build locally:

```bash
make build-sdcc-z80-idp
```

The build does this automatically:

- prepares `sdcc-z80-idp/libraries/`
- fetches the latest configured release bundles
- fetches the latest `ugpx` source snapshot
- builds the Docker image

## License

This image contains software from multiple upstream projects. License terms are those of the included components.

- SDCC: GPL-2.0-or-later
- Alpine packages: various open source licenses
- bundled upstream libraries and tools: see their respective repositories and release artifacts
