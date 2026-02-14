# Haiku Runtime Packages

Place the following Haiku package files (`.hpkg`) in this directory before building the Docker image:

## Required Files

1. **haiku-hrev57991-1-x86_64.hpkg** - Base Haiku runtime libraries
2. **haiku_devel-hrev57991-1-x86_64.hpkg** - Haiku development headers and libraries

## Where to Get These Files

### Option 1: Download from Official Haiku Package Repository

```bash
# Base URL for r1beta5 packages
REPO="https://eu.hpkg.haiku-os.org/haiku/r1beta5/x86_64/current/packages"

# Download base package
wget -O haiku-hrev57991-1-x86_64.hpkg \
  "$REPO/haiku-hrev57991-1-x86_64.hpkg"

# Download development package
wget -O haiku_devel-hrev57991-1-x86_64.hpkg \
  "$REPO/haiku_devel-hrev57991-1-x86_64.hpkg"
```

### Option 2: Extract from Haiku ISO

1. Download Haiku r1beta5 ISO from https://www.haiku-os.org/get-haiku/
2. Mount the ISO: `sudo mount -o loop haiku-r1beta5-x86_64-anyboot.iso /mnt`
3. Copy packages from: `/mnt/system/packages/`
   - `haiku-*.hpkg`
   - `haiku_devel-*.hpkg`

### Option 3: Copy from Running Haiku Installation

If you have Haiku installed (VM or physical):
```bash
# Packages are located at:
/boot/system/packages/haiku-*.hpkg
/boot/system/packages/haiku_devel-*.hpkg
```

## What's Inside These Packages

**haiku-hrev57991-1-x86_64.hpkg** contains:
- Runtime libraries: `libroot.so`, `libbe.so`, `libnetwork.so`, etc.
- C runtime objects: `crt0.o`, `crti.o`, `crtn.o`
- System binaries and data files

**haiku_devel-hrev57991-1-x86_64.hpkg** contains:
- Development headers: `/boot/system/develop/headers/`
  - `os/` - Haiku OS/BeAPI headers
  - `posix/` - POSIX headers
  - `config/` - Configuration headers
  - `gnu/`, `bsd/` - Compatibility headers
- Static libraries for development

## File Size

These files are approximately:
- haiku-*.hpkg: ~40-60 MB
- haiku_devel-*.hpkg: ~5-10 MB

## .gitignore

The `.hpkg` files are excluded from git (see `.gitignore`) since they are large binaries. Each developer needs to download them locally before building the image.