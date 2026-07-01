# XCC Z80 for Iskra Delta Partner

`wischner/xcc-z80-idp` is the Iskra Delta Partner variant of the packaged
XYZ Z80 compiler suite image.

Right now it is a clean scaffold on top of `wischner/xcc-z80` with reserved
paths for future Partner-specific headers, libraries, and helper tooling.

## What is included

- everything from `wischner/xcc-z80`
- `/opt/idp/include`
- `/opt/idp/lib`
- `/opt/idp/libraries`
- `/opt/idp/libraries.manifest`

## What this image is for

- compiling Z80 code with `xcc`, `xas`, and `xld`
- preparing a stable home for Iskra Delta Partner-specific additions
- giving Partner projects a future-proof image name before the extra libraries land

## Quick start

Compile a program:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/xcc-z80-idp:latest \
  xcc hello.c -o hello.xl
```

Open an interactive shell:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/work -w /work \
  wischner/xcc-z80-idp:latest \
  bash
```

## Support

Issues and pull requests are welcome:
<https://github.com/wischner/docker-toolchains>
