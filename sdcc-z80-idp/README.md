# SDCC Z80 – Iskra Delta Partner

SDCC Z80 toolchain tailored for **Iskra Delta Partner** development with `cpmdisk` and wrapped SDCC defaults.

## What's included

- **SDCC Z80 compiler** (from base sdcc-z80 image)
- **uCsim Z80 simulator** (from base sdcc-z80 image)
- **cpmdisk** - Iskra Delta Partner compatible CP/M disk tool
- **Wrapped SDCC defaults**
  - `/opt/sdcc/share/sdcc/include` is replaced by headers from synced bundles
  - `/opt/sdcc/share/sdcc/lib/z80` is replaced by bundled `crt0.rel` + merged `z80.lib`
  - library startup objects like `crt0cpm3-z80.rel` are normalized to `crt0.rel`

## Base image

Built on `wischner/sdcc-z80:latest` (Alpine Linux with SDCC)

## Usage

### Interactive shell

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:latest \
  bash
```

### Compile for Iskra Delta Partner

Use `sdcc` directly (wrapped defaults are already in standard SDCC paths):

Create `hello.c`:

```c
#include <stdio.h>

int main(void) {
    puts("Hello, Iskra Delta Partner!");
    return 0;
}
```

Compile with SDCC:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:latest \
  sdcc -o hello.ihx hello.c
```

Convert IHX to CP/M `.com`:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:latest \
  sdobjcopy -I ihex -O binary hello.ihx hello.com
```

### Create CP/M disk images

```bash
# 1) Create Iskra Delta Partner floppy image (.img extension is fine)
#    Use built-in Partner floppy format: idpfdd
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:latest \
  cpmdisk create partner-floppy.img idpfdd --label PARTNER --datestamp

# 2) Add compiled hello.com to user area 0
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:latest \
  cpmdisk add partner-floppy.img -u 0 hello.com

# 3) Verify image contents
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:latest \
  cpmdisk info partner-floppy.img
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:latest \
  cpmdisk list partner-floppy.img -u 0
```

## Library bundles

Bundles are synced automatically from GitHub releases based on `libraries.manifest`:

```
sdcc-z80-idp/
├── libraries.manifest     # <owner/repo> [tag|latest]
├── libraries/             # generated at build prepare step
│   └── <bundle-name>/
│       ├── lib/
│       └── include/
├── Dockerfile
├── build.args
└── README.md
```

## Building the image

```bash
make build-sdcc-z80-idp
```

`make build-sdcc-z80-idp` now auto-syncs all bundles from `libraries.manifest` before the Docker build by running `sdcc-z80-idp/Makefile.toolchain`.

Manifest example:

```text
# <github_repo> [release_tag_or_latest]
retro-vault/libsdcc-z80 latest
retro-vault/libcpm3-z80 latest
```

## License

- SDCC (GPL-2.0-or-later)
- Alpine Linux components (various open source licenses)
