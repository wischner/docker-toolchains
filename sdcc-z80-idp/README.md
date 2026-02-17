# SDCC Z80 – Iskra Delta Partner

SDCC Z80 toolchain tailored for **Iskra Delta Partner** development with CP/M disk image tools and wrapped SDCC defaults.

## What's included

- **SDCC Z80 compiler** (from base sdcc-z80 image)
- **uCsim Z80 simulator** (from base sdcc-z80 image)
- **cpmtools** - CP/M disk image creation and manipulation
- **Wrapped SDCC defaults**
  - `/opt/sdcc/share/sdcc/include` is replaced by headers from synced bundles
  - `/opt/sdcc/share/sdcc/lib/z80` is replaced by bundled `crt0.rel` + merged `z80.lib`

## Base image

Built on `wischner/sdcc-z80:latest` (Alpine Linux with SDCC)

## Usage

### Interactive shell

```bash
docker run --rm -it \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:latest \
  bash
```

### Compile for Iskra Delta Partner

Use the convenience wrapper (wrapped defaults):

```bash
docker run --rm -it \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:latest \
  idp-sdcc -o program.ihx program.c
```

Or use `sdcc` directly:

```bash
docker run --rm -it \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:latest \
  sdcc -mz80 -o program.ihx program.c
```

### Create CP/M disk images

```bash
# Create a new disk image
docker run --rm -it \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:latest \
  mkfs.cpm -f partner disk.img

# Copy files to disk image
docker run --rm -it \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:latest \
  cpmcp -f partner disk.img program.com 0:
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
├── local-libraries/       # local bundle overrides committed in this repo
│   └── <bundle-name>/
│       ├── lib/
│       └── include/
├── Dockerfile
├── build.args
└── README.md
```

`crt0.rel` is currently provided by `local-libraries/partner/lib/crt0.rel`.

## Building the image

```bash
make build-sdcc-z80-idp
```

`make build-sdcc-z80-idp` now auto-syncs all bundles from `libraries.manifest` before the Docker build by running `sdcc-z80-idp/Makefile.toolchain`.

Manifest example:

```text
# <github_repo> [release_tag_or_latest]
retro-vault/libsdcc-z80 latest
```

## License

- SDCC (GPL-2.0-or-later)
- cpmtools (GPL-3.0)
- Alpine Linux components (various open source licenses)
