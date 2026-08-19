# `xcc-z80-idp` image contents

This document inventories the toolchain and application payload intentionally
installed in `wischner/xcc-z80-idp:2.3.2`. The image is based on Ubuntu 24.04
for Linux x86-64. Ubuntu's standard runtime files, packages, and transitive
shared-library dependencies are not enumerated file by file.

## Versions and sources

| Component | Version | Source |
| --- | --- | --- |
| Image | 2.3.2 | This package |
| XCC Z80 toolchain | 2.3.2 | Inherited from `wischner/xcc-z80:2.3.2` |
| Build tools | Ubuntu 24.04 packages | GNU Make, CMake, and Git |
| Partner `libgpx` | 0.2.0 | [retro-vault/libgpx](https://github.com/retro-vault/libgpx) |
| IDP μgpx | Latest `main` at image build time | [iskra-delta/idp-udev](https://github.com/iskra-delta/idp-udev) |
| IDP SDK | Latest `main` at image build time | [iskra-delta/idp-sdk](https://github.com/iskra-delta/idp-sdk) |
| Snatch | 1.0.0 | [retro-vault/snatch](https://github.com/retro-vault/snatch) |
| CP/M disk tool | 1.1.0 | [iskra-delta/cpmdisk](https://github.com/iskra-delta/cpmdisk) |

Installed component revisions are also recorded in `/opt/idp/share/metadata`.
The XCC version and source metadata are stored in `/opt/x/.version` and
`/opt/x/.source`.

idp-udev and idp-sdk intentionally follow the current tip of `main` instead of
pinned commits. The exact commits resolved for a particular image build are
stored in `/opt/idp/share/metadata/idp-udev.version` and
`/opt/idp/share/metadata/idp-sdk.version`.

## Runtime defaults

- Default user: `ubuntu`
- Home directory: `/home/ubuntu`
- Working directory: `/work`
- Host architecture: Linux x86-64
- Default XCC/XLD target platform: CP/M 3

`/usr/local/bin/xcc` and `/usr/local/bin/xld` are small wrappers around the
real programs in `/opt/x/bin`. They add `--platform=cpm3` by default, selecting
the CP/M 3 startup code, runtime, and linker configuration. The only other
supported target is `emu`, selected explicitly:

```sh
xcc --platform=emu program.c
xld --platform=emu objects.rel
```

The wrappers reject every platform name except `cpm3` and `emu`. They also
reject attempts to link full `libgpx` and micro `libugpx` together. Bare-metal
`none` startup files, libraries, linker scripts, and their unsuffixed aliases
are removed from the image.

The image defines these toolchain-specific environment variables:

| Variable | Value |
| --- | --- |
| `XTOOLS_ROOT` | `/opt/x` |
| `IDP_ROOT` | `/opt/idp` |
| `IDP_INCLUDE_DIR` | `/opt/idp/include` |
| `IDP_LIB_DIR` | `/opt/idp/lib` |
| `SNATCH_PLUGIN_DIR` | `/opt/snatch/plugins` |

`/usr/local/bin` and `/opt/x/bin` are on `PATH`, so the wrapped compiler and
linker, all other XCC tools, GNU Make, CMake, Git, `snatch`, and `cpmdisk` can
be invoked directly.

## XCC Z80 toolchain

The complete XCC 2.3.2 suite is installed in `/opt/x/bin`:

| Command | Purpose |
| --- | --- |
| `xcc` | C compiler driver; defaults to CP/M 3 in this image |
| `xas` | Z80 assembler |
| `xld` | Linker; defaults to CP/M 3 in this image |
| `xar` | Static-library archiver |
| `xobjcopy` | Object and binary format conversion |
| `xopt` | Z80 optimizer |
| `xemu` | Z80 emulator with Partner-compatible RAM banking by default |
| `xgdb` | Debugger |
| `xgdb-z80` | Compatibility alias for the XEMU remote target |

The original, unwrapped `xcc` and `xld` executables remain available as
`/opt/x/bin/xcc` and `/opt/x/bin/xld`.

### Z80 public headers

XCC's target headers are in `/opt/x/z80/include`:

```text
assert.h       complex.h      ctype.h        errno.h
fcntl.h        fenv.h         float.h        inttypes.h
iso646.h       limits.h       locale.h       math.h
setjmp.h       signal.h       stdalign.h     stdarg.h
stdatomic.h    stdbit.h       stdbool.h      stdckdint.h
stddef.h       stdint.h       stdio.h        stdlib.h
stdnoreturn.h  string.h       strings.h      sys.h
tgmath.h       threads.h      time.h         uchar.h
unistd.h       wchar.h        wctype.h       yos.h
sys/bdos.h     sys/stat.h     sys/types.h
```

The IDP additions `libgpx.h`, `ugpx.h`, and `partner/` are linked into the same
directory. Choose one graphics interface when including and linking:

```c
#include <libgpx.h>       /* full graphics */
/* or: #include <ugpx.h>  -- micro graphics */
#include <partner/conio.h>
```

### Z80 startup files, libraries, and linker scripts

XCC target objects and libraries are in `/opt/x/z80/lib`:

```text
crt0-cpm3.rel       crt0-cpm3.s
crt0-emu.rel        crt0-emu.s

libc.a              libcpm3.a
libemu.a            libfixed.a
libruntime.a        libgpx.a
libugpx.a
libsdk.a

linker-cpm3.ld      linker-cpm3.lk
linker-emu.ld       linker-emu.lk
```

`libgpx.a`, `libugpx.a`, and `libsdk.a` in this directory point to the
corresponding IDP libraries under `/opt/idp/lib`. `libcpm3.a` is XCC's native
CP/M 3 runtime.

The two installed platform variants are:

- `cpm3`: CP/M 3 startup, runtime, and linker layout; the image default.
- `emu`: the XCC emulator platform.

### Partner-compatible XEMU banking

XEMU remains version 2.3.2, with a small downstream extension that allows a
memory-map port rule to assign a fixed selector value on either `IN` or `OUT`.
This is necessary because Partner selects RAM banks from the port address and
ignores the byte transferred.

The default configuration is `/etc/xemu/partner.conf`, exposed to XEMU through
`/home/ubuntu/.config/x/xemu.conf`. It models:

| CPU address range | Partner memory |
| --- | --- |
| `0x0000–0xBFFF` | 48 KiB window over two physical RAM banks |
| `0xC000–0xFFFF` | 16 KiB common RAM, visible in both banks |

Bank selection follows Partner's low-byte I/O decoding for both input and
output operations:

| I/O port range | Selected bank |
| --- | --- |
| `0x88–0x8F` | Physical bank 1 |
| `0x90–0x97` | Physical bank 2 |

The initial selection is physical bank 1. A project-local `./xemu.conf` or an
explicit `xemu --config FILE` can replace the image default. This configuration
models Partner RAM banking; it does not claim to emulate the complete Partner
peripheral set or boot-ROM overlay.

## Partner and IDP target libraries

The IDP target payload has a canonical home at `/opt/idp`. Its public headers
and libraries are also exposed through XCC's normal search directories, so no
extra `-I` or `-L` option is required.

### Partner `libgpx`

Partner's `libgpx` is assembled with XCC's `xas` and archived with `xar`.

| Item | Installed location |
| --- | --- |
| Public header | `/opt/idp/include/libgpx.h` |
| Static library | `/opt/idp/lib/libgpx.a` |
| Compatibility library name | `/opt/idp/lib/libgpx.lib` |
| XCC header link | `/opt/x/z80/include/libgpx.h` |
| XCC library link | `/opt/x/z80/lib/libgpx.a` |

Link it with `-lgpx`.

### IDP μgpx

Only the μgpx component from idp-udev is packaged. Its C sources are compiled
with `xcc`, its Z80 sources are assembled with `xas`, and the result is archived
with `xar`. The μlibc and μsdcc components are not built or installed.

| Item | Installed location |
| --- | --- |
| Public header | `/opt/idp/include/ugpx.h` |
| Static library | `/opt/idp/lib/libugpx.a` |
| Compatibility library name | `/opt/idp/lib/libugpx.lib` |
| XCC header link | `/opt/x/z80/include/ugpx.h` |
| XCC library link | `/opt/x/z80/lib/libugpx.a` |

Link it with `-lugpx`. μgpx and full `libgpx` are mutually exclusive: never
link `-lugpx` and `-lgpx` into the same program. The wrapped `xcc` and `xld`
commands enforce this rule for normal library options and archive paths.

### IDP SDK

Only the SDK's XCC-compatible library and public Partner headers are packaged.
The public headers under `/opt/idp/include/partner` are:

| Header | Interface area |
| --- | --- |
| `bcd.h` | Binary-coded decimal helpers |
| `clock.h` | Clock services |
| `conio.h` | Console input/output |
| `debug.h` | Debug support |
| `mouse.h` | Mouse services |
| `serial.h` | Serial communication |
| `timer.h` | Timer services |

The SDK library is installed as:

| Item | Installed location |
| --- | --- |
| Public headers | `/opt/idp/include/partner` |
| Static library | `/opt/idp/lib/libsdk.a` |
| Compatibility library name | `/opt/idp/lib/libsdk.lib` |
| XCC header link | `/opt/x/z80/include/partner` |
| XCC library link | `/opt/x/z80/lib/libsdk.a` |

Link it with `-lsdk`. The image deliberately does not inject SDK initialization
code. Programs initialize only the subsystems they use, such as calling the
console initialization routine before using console services.

## Build tools

GNU Make, CMake, and Git are installed from Ubuntu 24.04 and remain available
in the final image. This allows a mounted project to configure, build, and use
source-control operations without installing extra host packages.

## Snatch

Snatch's executable and runtime plugins are installed under `/opt/snatch`, with
`/usr/bin/snatch` pointing to `/opt/snatch/snatch`. Its plugin directory is
selected by `SNATCH_PLUGIN_DIR=/opt/snatch/plugins`. Snatch development headers
are not installed.

Installed plugins in `/opt/snatch/plugins`:

```text
dither_1bpp_transform.so
dummy.so
fzx_transform.so
image_extractor.so
image_passthrough_extractor.so
partner_bitmap_transform.so
partner_sdcc_asm_bitmap.so
partner_sdcc_asm_tiny.so
partner_tiny_bin_extractor.so
partner_tiny_raster_transform.so
partner_tiny_transform.so
png.so
raw_bin.so
raw_c.so
ttf_extractor.so
```

## CP/M disk tool

The `cpmdisk` executable and its required runtime shared library are installed
under `/opt/cpmdisk`, with `/usr/bin/cpmdisk` pointing to the executable. It can
create and inspect CP/M disk images and list, add, extract, rename, copy, and
remove files. It also provides boot-sector read/write and system-generation
operations. Its development headers are not installed.

Installed files:

```text
/opt/cpmdisk/cpmdisk
/opt/cpmdisk/libcpmdisk.so
```

Host-system links make the command and its runtime library available in
conventional locations:

```text
/usr/bin/cpmdisk         -> /opt/cpmdisk/cpmdisk
/usr/lib/libcpmdisk.so   -> /opt/cpmdisk/libcpmdisk.so
```

## Additional XCC host files

The inherited XCC host-side static libraries remain available for the installed
compiler, emulator, optimizer, object-file support, debugger, and Z80 model.
The associated host-development headers under `/opt/x/include` are deliberately
removed from this image. This does not affect the public Z80 target headers in
`/opt/x/z80/include`.

Static libraries under `/opt/x/lib`:

```text
librsp.a
libxbfd.a
libxemu.a
libxgdb.a
libxgdb_cli.a
libxgdb_mi.a
libxopt.a
libxz80.a
```

Tool documentation is under `/opt/x/share/doc`:

```text
XAR.md
XAS.md
XCC.md
XEMU.md
XGDB.md
XLD.md
XOBJCOPY.md
XOPT.md
```

For compatibility, `/opt/xtools` points to `/opt/x`, and
`/etc/profile.d/x.sh` configures the XCC environment for login shells.

## Filesystem layout

```text
/opt/x/                         XCC 2.3.2 host and Z80 toolchain
  bin/                          compiler, assembler, linker, and tools
  lib/                          XCC host static libraries
  share/doc/                    tool documentation
  z80/include/                  target headers and IDP header links
  z80/lib/                      CP/M 3 and emu runtime/linker files

/opt/idp/                       canonical IDP target package
  include/libgpx.h              Partner full graphics header
  include/ugpx.h                Partner micro graphics header
  include/partner/              public IDP SDK headers
  lib/libgpx.a                  Partner graphics library
  lib/libugpx.a                 Partner micro graphics library
  lib/libsdk.a                  IDP SDK library
  libraries.manifest            packaged-library manifest
  share/licenses/               source-project licenses
  share/metadata/               pinned component versions

/opt/snatch/                    Snatch executable and runtime plugins
/opt/cpmdisk/                   cpmdisk executable and runtime shared library
/etc/xemu/partner.conf          default Partner RAM banking map
/usr/local/bin/xcc              CP/M 3-default compiler wrapper
/usr/local/bin/xld              CP/M 3-default linker wrapper
/usr/bin/snatch                 Snatch command link
/usr/bin/cpmdisk                cpmdisk command link
/usr/bin/make                   GNU Make
/usr/bin/cmake                  CMake
/usr/bin/git                    Git
/work                           default working directory
```

## Basic use

Compile and link an IDP SDK program for the default CP/M 3 platform:

```sh
xcc -o app.com app.c -lsdk
```

Use Partner graphics:

```sh
xcc -o graphics.com graphics.c -lgpx
```

Use Partner micro graphics instead:

```sh
xcc -o micro.com micro.c -lugpx
```

Do not combine `-lgpx` and `-lugpx`; the wrappers reject that link.

Use both libraries:

```sh
xcc -o demo.com demo.c -lsdk -lgpx
```

Build and run a flat emulator program with Partner-compatible banking:

```sh
xcc --platform=emu --oformat=binary -o app.bin app.c
xemu --run --load-bin app.bin --origin 0x0000 --pc 0x0000
```

Run the host utilities directly:

```sh
make --version
cmake --version
git --version
snatch --help
cpmdisk --help
```

## Intentional exclusions

The following files and components are deliberately not included:

- IDP SDK internal headers from `lib/include/hw`; only public headers are
  exposed.
- `sdkinit.rel`; applications control initialization of each SDK subsystem.
- The SDK's `libsdcc-z80.lib` and `libcpm3-z80.lib`.
- The SDCC compiler and SDCC runtime libraries.
- idp-udev's μlibc and μsdcc libraries, CRT, root replacement C headers, and
  internal build files. Only public `ugpx.h` and `libugpx.a` are packaged.
- Snatch development headers and other non-runtime release-package files.
- cpmdisk development headers and other non-runtime release-package files.
- XCC host-development headers under `/opt/x/include`; Z80 target headers under
  `/opt/x/z80/include` remain installed.
- The XCC `none` platform, including `crt0-none.*`, `libnone.a`,
  `linker-none.*`, and the equivalent unsuffixed bare-metal aliases.
- Source trees and intermediate build objects.

XCC's own `/opt/x/z80/lib/libcpm3.a` is present by design and is the CP/M 3
runtime selected by the image's default platform wrappers.

## Licenses and manifests

The source-project licenses for the packaged target libraries are installed at:

```text
/opt/idp/share/licenses/libgpx/LICENSE
/opt/idp/share/licenses/idp-udev/LICENSE
/opt/idp/share/licenses/idp-sdk/LICENSE
```

The target library inventory used by the image is preserved as
`/opt/idp/libraries.manifest`.
