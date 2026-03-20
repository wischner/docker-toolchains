# GCC ARM for Raspberry Pi Pico and Pico W

`wischner/gcc-arm-none-eabi-rpi-pico` is a Docker image for **Raspberry Pi Pico** and **Pico W** development on top of the generic `arm-none-eabi` base image.

It is built for RP2040 workflows and includes the pieces people usually want preinstalled: the Pico SDK, pico-extras, `pioasm`, `picotool`, OpenOCD, and a ready-to-use GNU embedded toolchain.

## What is included

- everything from `wischner/gcc-arm-none-eabi`
- Pico SDK at `/opt/pico-sdk`
- pico-extras at `/opt/pico-extras`
- `pioasm`
- `picotool`
- `ccache`
- `git-lfs`
- extra Pico host dependencies such as `libftdi` and `libudev`

## What this image is for

- Raspberry Pi Pico firmware builds
- Pico W projects
- RP2040 C and C++ development with CMake
- UF2 conversion and flashing with `picotool`
- SWD debugging with OpenOCD and GDB

## Quick start

Interactive shell with USB passthrough:

```bash
docker run --rm -it \
  --privileged \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$PWD":/work -w /work \
  wischner/gcc-arm-none-eabi-rpi-pico:latest \
  bash
```

Build a Pico project:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-arm-none-eabi-rpi-pico:latest \
  bash -c "cmake -S . -B build -DPICO_SDK_PATH=$PICO_SDK_PATH -DPICO_BOARD=pico_w && cmake --build build -j"
```

Convert ELF to UF2:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-arm-none-eabi-rpi-pico:latest \
  picotool uf2 convert build/your.elf -o build/your.uf2
```

## Environment

- `PICO_SDK_PATH=/opt/pico-sdk`
- `PICO_EXTRAS_PATH=/opt/pico-extras`
- `PICO_TOOLCHAIN_PATH=/usr`
- `CCACHE_DIR=/work/.ccache`
- Working directory: `/work`

## Notes

- USB access depends on host udev/device permissions.
- This image is aimed at Pico and RP2040 users. For a generic ARM bare-metal toolchain without Pico-specific content, use `wischner/gcc-arm-none-eabi`.

## Support

Issues and pull requests are welcome:
<https://github.com/wischner/docker-toolchains>
