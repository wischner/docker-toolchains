# SDCC Z80 for ZX Spectrum

**Support:** [wischner.co.uk/support](https://wischner.co.uk/support)

`wischner/sdcc-z80-zx-spectrum` is a Docker image for **ZX Spectrum development** with SDCC plus Spectrum-specific tooling and emulation support.

It extends the generic Z80 image with Fuse, `libspectrum`, conversion helpers, hdfmonkey with blank FAT16 HDF disk images, and a workflow that is friendly to RAM-loaded, ROM-based, and divIDE/esxDOS disk-based Spectrum software.

## What is included

- everything from `wischner/sdcc-z80`
- Fuse emulator
- `libspectrum`
- `bin2tap`
- convenience helpers such as `ihx2bin` and `ihx2tap`
- `hdfmonkey` for FAT filesystems inside HDF/raw IDE images (divIDE, DivMMC, +3e, Fuse),
  plus gzip-compressed blank FAT16 `ESXDOS` volumes of 16, 32, 64, and 128 MB
  under `$HDFMONKEY_IMAGE_DIR`
- bundled Spectrum ROMs

## What this image is for

- ZX Spectrum homebrew development
- TAP generation from SDCC output
- emulator-driven testing workflows
- projects that need an all-in-one compile and run environment

## Sample application

If you want a ready-made project that shows how to use this image, see:

- [`retro-vault/zxspec48-app`](https://github.com/retro-vault/zxspec48-app)

## Quick start

Build a RAM-loaded Spectrum program:

```bash
docker run --rm -it \
  -u $(id -u):$(id -g) \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-zx-spectrum:latest \
  bash -c "sdcc --code-loc 0x8000 --no-std-crt0 -DSPECTRUM crt0.rel hello.c && ihx2tap hello.ihx"
```

Run in Fuse over X11:

Before launching the emulator GUI from a Linux host over X11, allow your local Docker container to connect to the X server:

```bash
xhost +SI:localuser:$(whoami)
```

You can revoke that permission later with:

```bash
xhost -SI:localuser:$(whoami)
```

```bash
docker run --rm -it \
  -e DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$(pwd)":/work -w /work \
  wischner/sdcc-z80-zx-spectrum:latest \
  fuse hello.tap
```

Prepare an esxDOS disk image:

```bash
gunzip -c "$HDFMONKEY_IMAGE_DIR/blank-32m.hdf.gz" > disk.hdf
hdfmonkey put disk.hdf esxdos089/SYS esxdos089/BIN esxdos089/TMP /
hdfmonkey put disk.hdf hello.bin /HELLO.BIN
hdfmonkey ls disk.hdf
```

## Notes

- This image does not force a Spectrum-specific runtime model on your program.
- esxDOS firmware is not bundled; put your own distribution on the disk image.
- For ROM targets and special hardware initialization, you are expected to provide your own `crt0.rel`.

## CONTRIBUTE

Contributions are welcome. Please open an issue or pull request:
<https://github.com/wischner/docker-toolchains>
