# SDCC Z80 – Iskra Delta Partner

SDCC Z80 toolchain tailored for **Iskra Delta Partner** development with CP/M disk image tools.

## What's included

- **SDCC Z80 compiler** (from base sdcc-z80 image)
- **uCsim Z80 simulator** (from base sdcc-z80 image)
- **cpmtools** - CP/M disk image creation and manipulation
- **Partner-specific libraries** - Runtime libraries for Iskra Delta Partner
- **crt0.rel** - Partner startup code
- **Partner include files** - Headers for Partner system calls and hardware

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

Use the convenience wrapper that includes Partner libraries and headers:

```bash
docker run --rm -it \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:latest \
  idp-sdcc -o program.ihx program.c
```

Or use sdcc directly with Partner paths:

```bash
docker run --rm -it \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:latest \
  sdcc -mz80 -I/opt/partner/include -L/opt/partner/lib \
    /opt/partner/lib/crt0.rel -o program.ihx program.c
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

## Environment variables

- `PARTNER_HOME=/opt/partner` - Partner toolchain root
- `PARTNER_LIB=/opt/partner/lib` - Partner libraries location
- `PARTNER_INCLUDE=/opt/partner/include` - Partner include files location
- `C_INCLUDE_PATH` - Includes Partner headers

## Partner-specific files

Place your Partner-specific files in the `partner/` directory before building:

```
sdcc-z80-idp/
├── partner/
│   ├── crt0.rel           # Partner startup code
│   ├── lib/               # Partner runtime libraries
│   │   └── *.rel
│   └── include/           # Partner system headers
│       └── *.h
├── Dockerfile
├── build.args
└── README.md
```

## Building the image

```bash
make build-sdcc-z80-idp
```

## License

- SDCC (GPL-2.0-or-later)
- cpmtools (GPL-3.0)
- Alpine Linux components (various open source licenses)
