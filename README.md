# Wischner Ltd. Docker Toolchains

This repository contains a collection of **cross-compilation toolchains** packaged as Docker images.  
Each image provides a ready-to-use compiler and related tools for retrocomputing, embedded, or bare-metal development.

All images are published under the `wischner` namespace on Docker Hub.

---

## Available toolchains

- [**SDCC Z80 toolchain**](./sdcc-z80)  
  Small Device C Compiler 4.5.0 with Z80 backend only, plus `uCsim` (`sz80` Z80 simulator).  
  *Lean Z80 C toolchain in a container; assemble, link, and simulate Z80 programs.*

- [**GCC ARM (arm-none-eabi) toolchain**](./gcc-arm-none-eabi)  
  ARM bare-metal GCC (xPack build), with GDB and OpenOCD.  
  *Cross-compile and debug Cortex-M targets (incl. Raspberry Pi Pico) in one image.*

- [**GCC m68k toolchain**](./gcc-m68k)  
  GCC and binutils cross-compiler targeting `m68k-elf`.  
  *Develop for classic Motorola 68k systems like Atari ST and Amiga.*

---

## Usage

All images mount your current working directory into `/work` inside the container.

**SDCC Z80**

```bash
docker run --rm -it -v "$(pwd)":/work wischner/sdcc-z80:latest sdcc -mz80 hello.c
```

**ARM bare-metal**

```bash
docker run --rm -it -v "$(pwd)":/work wischner/gcc-arm-none-eabi:latest arm-none-eabi-gcc -o blink.elf blink.c
```

**m68k**

```bash
docker run --rm -it -v "$(pwd)":/work wischner/gcc-m68k:latest m68k-elf-gcc -o hello.elf hello.c
```

---

## Building locally

A generic **Makefile** auto-discovers subfolders with a `Dockerfile` and builds/pushes them.

List detected toolchains:

```bash
make list
```

Build all (tags `:latest` and `:${IMG_VER}`):

```bash
make build-all
```

Push all to Docker Hub (override org/version as needed):

```bash
make push-all ORG=wischner IMG_VER=1.0.0
```

Per-toolchain build arguments can be placed in `<toolchain>/build.args` (one `KEY=VAL` per line).  
They are passed automatically as `--build-arg KEY=VAL` during `docker build`.

---

## Contributing

Issues and PRs are welcome. Please:
- Keep images minimal and reproducible.
- Pin upstream versions in `build.args` where possible.
- Document any platform-specific helpers in the toolchain README.

---

## License

Each image bundles open-source components under their respective licenses (GPL, LGPL, etc.).  
See individual toolchain folders for details. The repository content is © Wischner Ltd., provided under a permissive license unless otherwise noted.
