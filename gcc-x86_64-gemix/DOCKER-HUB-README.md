# GCC x86_64 GEMix toolchain

**Support:** [wischner.co.uk/support](https://wischner.co.uk/support)

Ubuntu 22.04 based GCC toolchain for **GEMix (DRI GEM on Linux)** development.
The GEM SDK, bundled GEM programs, and Rasta viewer are built from GEM
release `v1.0.3` (`d940cf31ee9e85af0264a83abd1526d4475ffb0c`) during the image
build. That revision builds Rasta `5f1e1511e918e8b4dfa6f8b7a51272f66133ea0e`.
The [Native](https://github.com/wischner/native) C++ UI SDK `v0.9.1` is built
against it for both GEMix backends.

Includes:

- GCC, G++, CMake, pkg-config, gdb, SDL2, and the X11 base stack
- GEMix headers in `/usr/local/include` and `/opt/gemix/sdk/include`
- GEMix libraries in `/usr/local/lib`:
  `libaes.so`, `libvdi.so`, `librasta.so`, `libplatform_linux.so`, `libgem.so`,
  `libfat12.so`, `libmsa.so`, `libprg.so`, `libgemconf.a`, `libgemctl.a`,
  `libstout.a`, `libmusashi.a`
- Native SDK for GEMix in `/opt/gemix/native/hosted` (in-process AES/VDI)
  and `/opt/gemix/native/gemd` (gemd client): headers, `libnative.a`, link
  dependencies, and a CMake package (`find_package(Native)`)
- GEMix fonts and runtime resources in `/opt/gemix/share/gem`
- Programs on `PATH`: `rasta`, `gemd`, `desktop`, `terminal`, `calc`, `clock`,
  `stout`, `gemread`, `gemscape`, `ted`, `resgen`, and `gem-desktop`
- pkg-config entries for `gemix`, `gemix-aes`, `gemix-vdi`, `gemix-rasta`,
  `gemix-platform-linux`, `gemix-gem`, `gemix-gemconf`, `gemix-gemctl`,
  `gemix-fat12`, `gemix-msa`, `gemix-prg`, `gemix-stout`, `gemix-musashi`,
  `native-gemix`, and `native-gemix-gemd`

`GEM_RESOURCE_DIR` defaults to `/opt/gemix/share/gem`. `NATIVE_GEMIX_SDK` and
`NATIVE_GEMIX_GEMD_SDK` point at the two Native SDKs. `gem-desktop` starts
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
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-gemix:latest \
  bash -lc 'cmake -S . -B build -DCMAKE_PREFIX_PATH="$NATIVE_GEMIX_GEMD_SDK" && cmake --build build'
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
