# XCC Z80 for Iskra Delta Partner

`xcc-z80-idp` is the ready-to-use Iskra Delta Partner development image built
on [`xcc-z80`](../xcc-z80). It uses XCC's native CP/M 3 runtime by default and
adds the Partner SDK, full and micro graphics libraries, and disk/font host
tools.

Current image version: `2.0.2`

## Included components

- `wischner/xcc-z80:2.0.2`
- XCC's native CP/M 3 and emulator runtimes; no bare-metal `none` platform
- XEMU 2.0.2 with Partner-compatible RAM banking enabled by default
- GNU Make, CMake, and Git for project builds and source control
- [Partner libgpx](https://github.com/retro-vault/libgpx) `v0.2.0`, rebuilt
  with `xas`/`xar` as an independent `libgpx.a`
- Latest [idp-udev](https://github.com/iskra-delta/idp-udev) `main` at image
  build time: only μgpx, rebuilt with XCC as `libugpx.a`; μlibc and μsdcc
  are excluded
- Latest [idp-sdk](https://github.com/iskra-delta/idp-sdk) `main` at image
  build time, built with XCC
- [snatch](https://github.com/retro-vault/snatch) `v1.0.0`, including its
  plugins
- [cpmdisk](https://github.com/iskra-delta/cpmdisk) `v1.1.0`

The idp-sdk build deliberately contains only the XCC-built SDK archive and
public headers. It does **not** include `sdkinit.rel`, `libsdcc-z80.lib`,
`libcpm3-z80.lib`, or the SDCC CP/M startup object. Applications initialize
only the SDK subsystems they choose to use.

Only idp-udev's public `ugpx.h` and XCC-built μgpx archive are packaged. Its
root μlibc headers, μlibc library, μsdcc library, and CRT are excluded because
XCC supplies the C and CP/M 3 runtimes.

## Supported platforms

The image's `xcc` and `xld` commands add `--platform=cpm3` automatically. A
plain link therefore uses XCC's CP/M 3 startup code, `libcpm3.a`, and CP/M 3
linker script and produces a `.com`-style binary starting at `0x0100`.

Pass `--platform=emu` to compile or link for XEMU instead. The command wrappers
accept only `cpm3` and `emu`. The `none` platform payload and its equivalent
unsuffixed aliases are removed from the image.

## Headers and libraries

XCC and XLD discover the installed Partner content through their standard
target paths:

| Component | Header path | Library path | Link option |
|---|---|---|---|
| idp-sdk | `/opt/x/z80/include/partner/` | `/opt/x/z80/lib/libsdk.a` | `-lsdk` |
| Partner libgpx | `/opt/x/z80/include/libgpx.h` | `/opt/x/z80/lib/libgpx.a` | `-lgpx` |
| idp-udev μgpx | `/opt/x/z80/include/ugpx.h` | `/opt/x/z80/lib/libugpx.a` | `-lugpx` |

Only idp-sdk's public `include/partner` tree is packaged; its internal
`lib/include/hw` build headers are deliberately excluded. The canonical public
headers and libraries live below `/opt/idp/include` and `/opt/idp/lib`; entries
in the XCC directories are symlinks. All three archives are GNU-format archives
created by XCC's `xar`. XCC's host-development headers under `/opt/x/include`
are also excluded; the required Z80 target headers remain under
`/opt/x/z80/include`.

Use the SDK library without any automatic SDK startup code:

```bash
xcc app.c -lsdk -o app.com
```

Use libgpx independently:

```bash
xcc graphics.c -lgpx -o graphics.com
```

Use the smaller μgpx alternative:

```bash
xcc micro-graphics.c -lugpx -o micro-graphics.com
```

`libgpx` and `libugpx` are alternatives and must never be linked into the same
program. The image's `xcc` and `xld` wrappers reject a link containing both
`-lgpx` and `-lugpx`.

Use the SDK with either graphics library, for example:

```bash
xcc desktop.c -lsdk -lgpx -o desktop.com
```

No `-I`, `-L`, or `--platform=cpm3` option is required for these examples.

## Partner-compatible emulation

XEMU defaults to `/etc/xemu/partner.conf`, which models Partner's two 48 KiB
RAM banks at `0x0000–0xBFFF` and the 16 KiB common region at
`0xC000–0xFFFF`. Physical bank 1 is selected by any `IN` or `OUT` in
`0x88–0x8F`; physical bank 2 is selected by `0x90–0x97`. Bank 1 is active at
startup.

XEMU 2.0.2 is rebuilt with a narrow downstream patch because Partner selects
the bank from the port address and ignores the transferred byte. A local
`./xemu.conf` or explicit `xemu --config FILE` overrides the image default.
The default models Partner RAM banking, not the full peripheral set or ROM
overlay.

Build and run an emulator binary:

```bash
xcc --platform=emu --oformat=binary app.c -o app.bin
xemu --run --load-bin app.bin --origin 0x0000 --pc 0x0000
```

## Host and build tools

GNU Make, CMake, Git, `snatch`, and `cpmdisk` are directly available on `PATH`:

```bash
make --version
cmake --version
git --version
snatch --help
cpmdisk create partner.dsk fdd
cpmdisk add partner.dsk app.com
```

The snatch executable and its runtime plugins are installed at `/opt/snatch`;
its development headers are not packaged. `SNATCH_PLUGIN_DIR` points to
`/opt/snatch/plugins`. The cpmdisk executable and the `libcpmdisk.so` shared
object it needs at runtime are installed at `/opt/cpmdisk`; cpmdisk development
headers are not packaged. The published host-tool assets currently make this
image an x86-64 image.

## Quick start

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80-idp:2.0.2 \
  xcc app.c -lsdk -o app.com
```

Open an interactive shell:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80-idp:2.0.2 \
  bash
```

Versioned component refs live in [`build.args`](./build.args), while
[`libraries.manifest`](./libraries.manifest) records the installed XCC target
libraries. idp-udev and idp-sdk intentionally follow their latest `main`; the
exact commits resolved during a build are recorded inside the image at
`/opt/idp/share/metadata/idp-udev.version` and
`/opt/idp/share/metadata/idp-sdk.version`.
