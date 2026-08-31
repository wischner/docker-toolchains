# Wischner Ltd. Docker Toolchains

This repository contains a collection of native and cross-compilation
**toolchains packaged as Docker images**. Each image provides a ready-to-use
compiler and related tools for retrocomputing, embedded, bare-metal, or desktop
development.

All images are published under the `wischner` namespace on Docker Hub.
Every image includes Python 3, available as `python3`.

> **Tip:** Pin a numbered image tag instead of `:latest` for repeatable builds.

---

## Release policy

The images are actively maintained and versioned independently. Each
toolchain's authoritative image version and pinned component revisions live in
its `build.args`; run `make print-versions` to see all effective image versions.
The `latest` tag moves with each published release, while numbered tags remain
available for reproducible builds.

---

## Available toolchains

- [**GCC ARM (arm-none-eabi)**](./gcc-arm-none-eabi)  
  Ubuntu-based ARM bare‑metal GCC/G++ (newlib), `gdb-multiarch`, and OpenOCD.  
  *Cross‑compile and debug Cortex‑M (and other ARM MCUs) in one image.*

- [**GCC ARM for Raspberry Pi Pico / Pico W**](./gcc-arm-none-eabi-rpi-pico)  
  Extends the base ARM image with the **Pico SDK**, `pico-extras`, and host tools **`pioasm`** + **`picotool`** on Ubuntu.  
  *Turn‑key RP2040 development over SWD (OpenOCD) or BOOTSEL USB (picotool).*

- [**SDCC Z80**](./sdcc-z80)  
  Small Device C Compiler (Z80 backend) plus `uCsim` Z80 simulator.  
  *Lean Z80 C toolchain for classic 8‑bit targets.*

- [**XCC Z80**](./xcc-z80)
  Ubuntu-based packaged XYZ `xtools` prefix with `xcc`, `xas`, `xld`, and `xgdb`.
  *Use the already-built `retro-vault/xyz` Z80 compiler suite directly in a light Ubuntu image.*

- [**XCC Z80 – Iskra Delta Partner**](./xcc-z80-idp)
  XCC-based Partner toolchain with SDK libraries, libsquid, the PAKET package
  manager, host utilities, full idp-emu, and invisible Partner MCP.
  *Compile, package, network, emulate, and let AI inspect or run the real Partner hardware model.*

- [**XCC Z80 – ZX Spectrum**](./xcc-z80-zx-spectrum)
  Medium-model XCC with native ZX RAM/ROM targets, libgpx, libsquid, Beepolix,
  ZX Spectrum MCP, and snatch.
  *A complete compile, package, graphics, music, asset, and headless-emulation workflow.*

- [**XCC Z80 – Amstrad CPC**](./xcc-z80-cpc)
  Medium-model XCC with native CPC 464/664/6128 firmware targets, CDT and DSK
  packaging, libgpx, an emulator with an Amstrad CPC MCP, and the standard
  disk, graphics, and compression tools.
  *Compile, package, convert, compress, emulate, and let AI drive a real CPC model.*

- [**SDCC Z80 – ZX Spectrum**](./sdcc-z80-zx-spectrum)
  Z80 toolchain variant tailored for **ZX Spectrum** builds.
  *Convenient defaults/structure for Spectrum projects.*

- [**SDCC Z80 – Iskra Delta Partner**](./sdcc-z80-idp)
  SDCC toolchain with Partner SDK/graphics libraries, disk utilities, full
  idp-emu, and invisible Partner MCP.
  *A complete Partner compile, package, emulation, and AI-controlled runtime.*

- [**SDCC Z80 – CP/M 3**](./sdcc-z80-cpm3)
  Z80 toolchain variant tailored for **CP/M 3** workflows.
  *CP/M disk image creation and CP/M 3-oriented bundled runtime libraries.*

- [**GCC m68k**](./gcc-m68k)
  Modern GCC/G++ 16.1 and Binutils 2.46.1 targeting freestanding **`m68k-elf`**.
  *Develop bare-metal Motorola 68k systems with C or modern C++.*

- [**GCC m68k AmigaOS**](./gcc-m68k-amiga)
  Standalone AmigaPorts GCC/G++ 16.1 **`m68k-amigaos`** toolchain with the NDK,
  runtimes, debugger, all optional SDKs, ADF/HDF/ROM utilities, headless
  execution, graphics/audio converters, and Shrinkler.
  *Build, test, convert assets, compress, and package complete AmigaOS projects.*

- [**GCC x86_64 Linux X11**](./gcc-x86_64-linux-x11)
  GCC x86_64 toolchain with **X11**, original **Athena widgets (libXaw)**, OpenGL (Mesa), image/font tooling, Xephyr, and Xvfb on Ubuntu 22.04.
  *Native X11/OpenGL development and reusable Linux desktop base image.*

- [**GCC x86_64 GEMix**](./gcc-x86_64-gemix)
  GCC x86_64 toolchain layered on the X11 image with the hosted **GEMix**
  headers, shared libraries, pkg-config metadata, fonts, and runtime resources.
  *Build and run DRI GEM applications natively on Linux.*

- [**GCC x86_64 Linux Open Motif**](./gcc-x86_64-linux-motif)
  GCC x86_64 toolchain layered on the X11 image with the complete shared/static **Open Motif** SDK, `uil`, `mwm`, GLw, CMake/pkg-config metadata, and contained Xephyr testing.
  *Native Motif desktop development and legacy X11 GUI maintenance.*

- [**GCC x86_64 Linux GNUstep**](./gcc-x86_64-linux-gnustep)
  GCC x86_64 toolchain layered on the X11 image with **GNUstep**, Objective-C / Objective-C++, `gnustep-make`, Gorm, and ProjectCenter.
  *Native GNUstep Foundation/AppKit development and OpenStep-style desktop software maintenance.*

- [**GCC x86_64 Linux OpenLook / XView**](./gcc-x86_64-linux-openlook)
  GCC x86_64 toolchain layered on the X11 image with the complete CMake-native **OpenLook/XView SDK**, `olwm`, and a self-contained Xephyr test session.
  *Native XView/OpenLook development and maintenance of classic `/usr/openwin` software.*

- [**GCC x86_64 Linux Window Maker / WINGs**](./gcc-x86_64-linux-window-maker)
  Complete **Window Maker/WINGs** environment layered on the X11 image with pinned source, shared/static SDK libraries, every optional feature, and contained Xephyr testing.
  *Native WINGs application development and Window Maker desktop maintenance.*

- [**GCC x86_64 Linux SDL**](./gcc-x86_64-linux-sdl)
  GCC x86_64 SDL toolchain layered on the Linux X11 base with SDL2, SDL3, audio, and multimedia support.
  *SDL2 and SDL3 game and multimedia application development.*

- [**GCC x86_64 Windows MinGW-w64**](./gcc-x86_64-windows-mingw-w64)
  GCC/MinGW-w64 cross-compilation toolchain for building 64-bit Windows binaries from Linux.
  *Cross-compile `.exe` and `.dll` targets with CMake support.*

- [**GCC x86_64 Haiku**](./gcc-x86_64-haiku)
  GCC cross-compiler targeting **Haiku OS** (x86_64-unknown-haiku) with Jam build system and bundled Haiku-native `gdb` / `gdbserver`.
  *Build Haiku OS and native Haiku applications.*

---

## Usage

The examples mount your current working directory at `/work` in the container.

### ARM bare‑metal (generic)
```bash
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-arm-none-eabi:1.2.0 \
  arm-none-eabi-gcc -mcpu=cortex-m3 -mthumb -Os \
    -ffunction-sections -fdata-sections \
    -Wl,--gc-sections -nostartfiles -specs=nosys.specs \
    -o app.elf app.c
```

### Raspberry Pi Pico / Pico W (RP2040)
```bash
# Interactive shell (with USB passthrough for flashing/debug)
docker run --rm -it --privileged \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$PWD":/work -w /work \
  wischner/gcc-arm-none-eabi-rpi-pico:1.2.0 bash

# Build a project (SDK baked at /opt/pico-sdk)
cmake -S . -B build -DPICO_SDK_PATH=/opt/pico-sdk -DPICO_BOARD=pico_w
cmake --build build -j
```

### SDCC Z80
```bash
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/sdcc-z80:latest \
  sdcc -mz80 -o hello.ihx hello.c
```

### SDCC Z80 – ZX Spectrum
```bash
# Build a RAM-loaded program and package it as a TAP image
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/sdcc-z80-zx-spectrum:latest \
  sh -lc 'sdcc --code-loc 0x8000 --no-std-crt0 -DSPECTRUM crt0.rel hello.c && ihx2tap hello.ihx'
```

### SDCC Z80 – CP/M 3
```bash
# Compile a CP/M program and add it to a new disk image
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/sdcc-z80-cpm3:latest \
  sh -lc 'sdcc -o hello.ihx hello.c && sdobjcopy -I ihex -O binary hello.ihx hello.com && cpmdisk create cpm3.img idpfdd && cpmdisk add cpm3.img -u 0 hello.com'
```

### XCC Z80
```bash
# Build a relocatable XL image with xcc
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xcc hello.c -o hello.xl
```

### XCC Z80 – Iskra Delta Partner
```bash
# Compile for Partner CP/M 3
docker run --rm -it -v "$(pwd)":/work -w /work \
  wischner/xcc-z80-idp:latest xcc hello.c -o hello.com

# Let an MCP client control the full Partner GDP hardware model
docker run --rm -i -v "$(pwd)":/work -w /work \
  wischner/xcc-z80-idp:latest idp-mcp --model gdp
```

### XCC Z80 – ZX Spectrum
```bash
# Build a ZX Spectrum RAM binary with libgpx, then package it as a TAP
docker run --rm -it -v "$(pwd)":/work -w /work \
  wischner/xcc-z80-zx-spectrum:latest \
  sh -lc 'xcc -Os --oformat=binary hello.c -lgpx -o hello.bin && xprog --tap hello.bin -o hello.tap --name HELLO'
```

### SDCC Z80 – Iskra Delta Partner
```bash
# Compile with Partner libraries and headers
docker run --rm -it -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:latest sdcc -o program.ihx program.c

# Create CP/M disk image
docker run --rm -it -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:latest cpmdisk create partner.img idpfdd

# Start the invisible Partner MCP server
docker run --rm -i -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-idp:latest idp-mcp --model gdp
```

### GCC m68k
```bash
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-m68k:latest \
  m68k-elf-g++ -std=c++23 -ffreestanding -c hello.cpp -o hello.o
```

### GCC m68k AmigaOS
```bash
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-m68k-amiga:latest \
  m68k-amigaos-g++ -std=c++23 -Os hello.cpp -o hello

# CMake uses the toolchain file exported by the image
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-m68k-amiga:latest \
  bash -lc 'cmake -S . -B build-amiga -DCMAKE_TOOLCHAIN_FILE="$CMAKE_TOOLCHAIN_FILE" && cmake --build build-amiga -j'
```

### GCC x86_64 Linux X11
```bash
# Compile an X11/OpenGL application
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-x11:latest \
  bash -lc 'gcc -o app main.c $(pkg-config --cflags --libs x11 xft gl)'
```

### GCC x86_64 GEMix
```bash
# Compile against the complete hosted GEMix SDK
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-gemix:latest \
  bash -lc 'gcc -o app main.c $(pkg-config --cflags --libs gemix)'
```

### GCC x86_64 Linux Open Motif
```bash
# Compile a Motif application
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-motif:latest \
  bash -lc 'gcc -o app main.c $(pkg-config --cflags --libs xm)'

# Compile a UIL file
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-motif:latest \
  uil layout.uil -o layout.uid

# Run the resulting GUI under mwm in a contained Xephyr session
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-motif:latest \
  motif-xephyr ./app
```

### GCC x86_64 Linux GNUstep
```bash
# Compile a GNUstep Foundation tool
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-gnustep:latest \
  bash -lc '. /usr/share/GNUstep/Makefiles/GNUstep.sh && gcc -o hello hello.m $(gnustep-config --objc-flags) $(gnustep-config --base-libs)'

# Build a GNUstep project with gnustep-make
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-gnustep:latest \
  bash -lc '. /usr/share/GNUstep/Makefiles/GNUstep.sh && make'
```

### GCC x86_64 Linux OpenLook / XView
```bash
# Compile an XView application
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-openlook:latest \
  bash -lc 'gcc -o app app.c $(pkg-config --cflags --libs xview)'

# Run it in the image's headless Xephyr + olwm session
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-openlook:latest \
  openlook-xephyr ./app
```

### GCC x86_64 Linux Window Maker / WINGs
```bash
# Compile a WINGs application
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-window-maker:latest \
  bash -lc 'gcc -o app app.c $(pkg-config --cflags --libs WINGs)'

# Run it in a contained Xephyr + Window Maker session
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-window-maker:latest \
  window-maker-xephyr ./app
```

### GCC x86_64 Linux SDL
```bash
# Compile an SDL2 application
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-sdl:latest \
  bash -lc 'gcc -o game main.c $(pkg-config --cflags --libs sdl2 SDL2_image SDL2_mixer SDL2_ttf gl)'

# Compile an SDL3 application
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-sdl:latest \
  bash -lc 'gcc -o game3 main.c $(pkg-config --cflags --libs sdl3)'

# CMake build
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-sdl:latest \
  bash -lc 'cmake -S . -B build && cmake --build build -j'
```

### GCC x86_64 Windows MinGW-w64
```bash
# Compile a Windows x64 executable
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-windows-mingw-w64:latest \
  x86_64-w64-mingw32-gcc -O2 -o hello.exe hello.c

# CMake cross-build
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-windows-mingw-w64:latest \
  bash -lc 'cmake -S . -B build-win -DCMAKE_TOOLCHAIN_FILE=/opt/toolchains/mingw-w64-x86_64.cmake && cmake --build build-win -j'
```

### GCC x86_64 Haiku
```bash
# Compile a Haiku application
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-haiku:latest \
  x86_64-unknown-haiku-gcc -o app.elf app.c

# Build with Jam
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-haiku:latest jam
```

---

## Building locally

A generic **Makefile** auto‑discovers subfolders with a `Dockerfile` and builds/pushes them.

List detected toolchains and their effective versions:
```bash
make list
make print-versions
```

Build all images. Each directory's `build.args` supplies its numbered tag, and
the build also creates `:latest`:
```bash
make build-all
```

Push all image tags and their matching `DOCKER-HUB-README.md` overviews to
Docker Hub:
```bash
make push-all ORG=wischner
```

Build or push a single image:

```bash
make build-xcc-z80-idp
make push-xcc-z80-idp ORG=wischner
```

Overview publishing reuses credentials from `docker login`. In CI, set
`DOCKERHUB_USERNAME` together with `DOCKERHUB_TOKEN` (or
`DOCKERHUB_PASSWORD`) instead. The host must provide `curl` and `jq`.

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
