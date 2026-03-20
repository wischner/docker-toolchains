# GCC m68k Bare-Metal Toolchain

`wischner/gcc-m68k` provides a Dockerized **`m68k-elf` GCC cross-toolchain** for Motorola 68000 development.

It is aimed at retrocomputing, hobbyist systems, and bare-metal projects where you want a predictable cross-compiler environment without installing the toolchain directly on the host.

## What is included

- `m68k-elf-gcc`
- `m68k-elf-as`
- `m68k-elf-ld`
- `m68k-elf-objcopy`
- `m68k-elf-objdump`
- `make`
- `git`

## What this image is for

- bare-metal 68000 development
- retro platforms such as Amiga, Atari ST, and Sega-era projects
- custom boards and hobby hardware using m68k CPUs

## Quick start

Interactive shell:

```bash
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-m68k:latest \
  bash
```

Compile and convert to binary:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-m68k:latest \
  bash -c "m68k-elf-gcc -o hello.elf hello.c && m68k-elf-objcopy -O binary hello.elf hello.bin"
```

## Notes

- This toolchain does not provide a target OS libc.
- Startup code, linker scripts, and target-specific runtime pieces are expected to come from your project.

## Support

Issues and pull requests are welcome:
<https://github.com/wischner/docker-toolchains>
