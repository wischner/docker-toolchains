# XCC Z80 for Iskra Delta Partner

`xcc-z80-idp` is a Docker image for **Iskra Delta Partner** development built on
top of [`xcc-z80`](../xcc-z80), the packaged XYZ Z80 compiler suite image.

Current image version: `1.0.1`

## What the image contains

Today this image is intentionally small. It includes:

- everything from `wischner/xcc-z80:1.9.9`
- a reserved Partner-specific root at `/opt/idp`
- placeholder include and library directories at `/opt/idp/include` and `/opt/idp/lib`
- a staging directory at `/opt/idp/libraries`
- a checked-in [`libraries.manifest`](./libraries.manifest) to track the next libraries we add

That means the image already works as a normal `xcc-z80` environment while
giving us a clean place to layer in Partner-specific runtime libraries, headers,
and tooling next.

## Toolchain layout

Inherited XCC tools live under:

- `/opt/x/bin`
- `/opt/x/include`
- `/opt/x/lib`
- `/opt/x/z80/include`
- `/opt/x/z80/lib`

Partner-specific content will live under:

- `/opt/idp/include`
- `/opt/idp/lib`
- `/opt/idp/libraries`

## Using the image

Open a shell:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/xcc-z80-idp:1.0.1 \
  bash
```

Compile a simple XCC program:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/xcc-z80-idp:1.0.1 \
  xcc hello.c -o hello.xl
```

Build a fixed-address flat binary:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/xcc-z80-idp:1.0.1 \
  xcc --oformat=binary -Ttext=0x8000 hello.c -o hello.bin
```

## Next step

No Iskra Delta Partner libraries are bundled yet. This image is the base
scaffold we will extend when you decide which Partner SDK pieces to add.
