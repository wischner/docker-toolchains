# XCC Z80 toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is

A lightweight **Ubuntu-based Z80 toolchain** that packages the published
Debian package from the latest `retro-vault/xyz` GitHub release.

In practice this gives you:

- `xcc` as the C11 compiler driver
- `xas`, `xld`, `xar`, and `xobjcopy`
- `xgdb` and `xgdb-z80` for debugging
- a staged Z80 target runtime under `z80/include` and `z80/lib`

## Installed components

- Upstream package prefix under `/opt/x`
- Tool binaries in `/opt/x/bin`
- Host SDK headers and libs in `/opt/x/include` and `/opt/x/lib`
- Target headers and runtime in `/opt/x/z80/include` and `/opt/x/z80/lib`

The image just adds `/opt/x/bin` to `PATH`. No extra environment variables are
required. It runs as a non-root user by default. For compatibility with older
revisions of this image, `/opt/xtools` is also available as a symlink to
`/opt/x`.

If you want files created on a bind mount to match your host UID/GID
exactly, add `-u $(id -u):$(id -g)` to `docker run`.

## Using this image

Compile a simple C program into a relocatable `XL` image:

```bash
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xcc hello.c -o hello.xl
```

Compile only, emitting a `.rel` object:

```bash
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xcc -c hello.c -o hello.rel
```

Build a fixed-address flat binary:

```bash
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xcc --oformat=binary -Ttext=0x8000 hello.c -o hello.bin
```

## SDK staging

The image build does **not** compile `retro-vault/xyz` itself. Instead,
`Makefile.toolchain` downloads the latest GitHub release Debian package
(`x_*_amd64.deb`) into [`sdk`](./sdk) as `x.deb`, and the Dockerfile installs
that package during the image build. As part of the same step, it also syncs
[`build.args`](./build.args) so `IMG_VERSION` matches the upstream three-part
release version, for example `1.7.2` from `x_1.7.2-1_amd64.deb`.

By default it tracks the current latest release. To stage a specific tag
instead, override `XYZ_VERSION` when preparing locally:

```bash
make -f Makefile.toolchain prepare XYZ_VERSION=vX.Y.Z
```

That keeps Docker rebuilds fast, avoids manually curating individual files, and
follows the upstream package layout under `/opt/x`.
