# GCC x86_64 GEMix toolchain

**Support:** [wischner.co.uk/support](https://wischner.co.uk/support)

Ubuntu 22.04 based GCC toolchain for **GEMix (DRI GEM on Linux)** development.
The GEM SDK, bundled GEM programs, and Rasta viewer are built from GEM
revision `03a9c1efdc67fef89abb9c1c3c5de9d42f133ecf` during the image build.
That revision builds Rasta `5f1e1511e918e8b4dfa6f8b7a51272f66133ea0e`.

Includes:

- GCC, G++, CMake, pkg-config, gdb, SDL2, and the X11 base stack
- GEMix headers in `/usr/local/include` and `/opt/gemix/sdk/include`
- GEMix libraries in `/usr/local/lib`:
  `libaes.so`, `libvdi.so`, `librasta.so`, `libplatform_linux.so`, `libgem.so`,
  `libfat12.so`, `libmsa.so`, `libprg.so`, `libgemconf.a`, `libgemctl.a`,
  `libstout.a`, `libmusashi.a`
- GEMix fonts and runtime resources in `/opt/gemix/share/gem`
- Programs on `PATH`: `rasta`, `gemd`, `desktop`, `terminal`, `calc`, `clock`,
  `stout`, `gemread`, `gemscape`, `resgen`, and `gem-desktop`
- pkg-config entries for `gemix`, `gemix-aes`, `gemix-vdi`, `gemix-rasta`,
  `gemix-platform-linux`, `gemix-gem`, `gemix-gemconf`, `gemix-gemctl`,
  `gemix-fat12`, `gemix-msa`, `gemix-prg`, `gemix-stout`, and `gemix-musashi`

`GEM_RESOURCE_DIR` defaults to `/opt/gemix/share/gem`. `gem-desktop` starts
Rasta, gemd, and the desktop in one container.

Example:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-gemix:latest \
  bash -lc 'gcc -o app main.c $(pkg-config --cflags --libs gemix)'
```

```bash
docker run --rm -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  wischner/gcc-x86_64-gemix:latest \
  gem-desktop
```

## CONTRIBUTE

Contributions are welcome. Please open an issue or pull request:
<https://github.com/wischner/docker-toolchains>
