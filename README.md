# Wischner Ltd. Docker Toolchains

This repository contains a collection of **cross-compilation toolchains** packaged as Docker images.  
Each image provides a ready-to-use compiler and related tools for retrocomputing, embedded, or bare‑metal development.

All images are published under the `wischner` namespace on Docker Hub.

> **Tip:** Pin specific tags (e.g. `:1.0.3`) instead of `:latest` to get repeatable builds.

---

## Project status & roadmap

This repository is **actively developed**. Next steps:
- Improve the repository’s **Scout health score**.
- **Stabilize** the ARM (`gcc-arm-none-eabi`) and **m68k** packages.
- The **Z80** packages (`sdcc-z80`, `sdcc-z80-zx-spectrum`) are **stable** today.
- After stabilization, all images will be released as **`2.0.0`**.

---

## Available toolchains

- [**GCC ARM (arm-none-eabi)**](./gcc-arm-none-eabi)  
  Alpine-native ARM bare‑metal GCC/G++ (newlib), `gdb-multiarch`, and OpenOCD.  
  *Cross‑compile and debug Cortex‑M (and other ARM MCUs) in one image.*

- [**GCC ARM for Raspberry Pi Pico / Pico W**](./gcc-arm-none-eabi-rpi-pico)  
  Extends the base ARM image with the **Pico SDK**, `pico-extras`, and host tools **`pioasm`** + **`picotool`**.  
  *Turn‑key RP2040 development over SWD (OpenOCD) or BOOTSEL USB (picotool).*

- [**SDCC Z80**](./sdcc-z80)  
  Small Device C Compiler (Z80 backend) plus `uCsim` Z80 simulator.  
  *Lean Z80 C toolchain for classic 8‑bit targets.*

- [**SDCC Z80 – ZX Spectrum**](./sdcc-z80-zx-spectrum)  
  Z80 toolchain variant tailored for **ZX Spectrum** builds.  
  *Convenient defaults/structure for Spectrum projects.*

- [**GCC m68k**](./gcc-m68k)  
  GCC/binutils cross‑compiler targeting **`m68k-elf`**.  
  *Develop for classic Motorola 68k systems (e.g., Atari ST, Amiga).*

---

## Usage

Each image mounts your current working directory into `/work` inside the container.

### ARM bare‑metal (generic)
```bash
docker run --rm -it   -v "$(pwd)":/work -w /work   wischner/gcc-arm-none-eabi:1.0.3   arm-none-eabi-gcc -mcpu=cortex-m3 -mthumb -o app.elf app.c
```

### Raspberry Pi Pico / Pico W (RP2040)
```bash
# Interactive shell (with USB passthrough for flashing/debug)
docker run --rm -it   --privileged -v /dev/bus/usb:/dev/bus/usb   -v "$(pwd)":/work -w /work   wischner/gcc-arm-none-eabi-rpi-pico:1.0.2 bash

# Build a project (SDK baked at /opt/pico-sdk)
cmake -S . -B build -DPICO_SDK_PATH=/opt/pico-sdk -DPICO_BOARD=pico_w
cmake --build build -j
```

### SDCC Z80
```bash
docker run --rm -it   -v "$(pwd)":/work -w /work   wischner/sdcc-z80:latest   sdcc -mz80 -o hello.ihx hello.c
```

### GCC m68k
```bash
docker run --rm -it   -v "$(pwd)":/work -w /work   wischner/gcc-m68k:latest   m68k-elf-gcc -o hello.elf hello.c
```

---

## Building locally

A generic **Makefile** auto‑discovers subfolders with a `Dockerfile` and builds/pushes them.

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
make push-all ORG=wischner IMG_VER=1.0.3
```

Per‑toolchain build arguments can be placed in `<toolchain>/build.args` (one `KEY=VAL` per line).  
They are passed automatically as `--build-arg KEY=VAL` during `docker build`.

> When you rebuild a **base** image, remember to **rebuild all derived** images that use `FROM` on that base tag.

---

## Contributing

Issues and PRs are welcome. Please:
- Keep images minimal and reproducible.
- Pin upstream versions in `build.args` where possible.
- Document any platform‑specific helpers in the toolchain README.

---

## License

Each image bundles open‑source components under their respective licenses (GPL, LGPL, etc.).  
See individual toolchain folders for details. The repository content is © Wischner Ltd., provided under a permissive license unless otherwise noted.