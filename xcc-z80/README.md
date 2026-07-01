# XCC Z80 toolchain

This image is part of **Wischner Ltd. Toolchains**.

## What it is

A lightweight **Ubuntu-based Z80 toolchain** that installs the published
large-model Linux bundle (`x-l-linux.zip`) from the `retro-vault/xyz` GitHub
releases.

In practice this gives you:

- `xcc` as the full-model C23 compiler driver
- `xas`, `xld`, `xar`, and `xobjcopy`
- `xgdb` and `xemu` for debugging, plus an `xgdb-z80` compatibility alias
- a staged Z80 target runtime under `z80/include` and `z80/lib`

## Installed components

- Upstream package prefix under `/opt/x`
- Tool binaries in `/opt/x/bin`
- Host SDK headers and libs in `/opt/x/include` and `/opt/x/lib`
- Target headers and runtime in `/opt/x/z80/include` and `/opt/x/z80/lib`

The image just adds `/opt/x/bin` to `PATH`. No extra environment variables are
required. It runs as a non-root user by default. For compatibility with older
revisions of this image, `/opt/xtools` is also available as a symlink to
`/opt/x`, and `/opt/x/bin/xgdb-z80` is kept as an alias to upstream `xemu`.

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

## Upstream bundle

The image build does **not** compile `retro-vault/xyz` itself. The Dockerfile
downloads the pinned upstream GitHub release bundle directly at build time and
installs it under `/opt/x`.

For this image we intentionally pin the **large** Linux bundle so the staged
libc keeps full `double` and `long long` support:

```text
XYZ_VERSION=v1.9.3
X_DIST=x-l-linux.zip
```

Those defaults live in [`build.args`](./build.args), alongside `IMG_VERSION`,
and can be overridden with normal Docker build arguments if you need to test a
different upstream tag later.
