# GCC x86_64 GEMix toolchain

**Support:** [wischner.co.uk/support](https://wischner.co.uk/support)

Ubuntu 22.04 based GCC toolchain for **GEMix (DRI GEM on Linux)** development.
The GEM SDK is built from the pinned `v1.0.0` release during the image build.

Includes:

- GCC, G++, CMake, pkg-config, gdb, and the X11 base stack
- GEMix headers in `/usr/local/include`
- GEMix shared libraries in `/usr/local/lib`:
  `libaes.so`, `libvdi.so`, `librasta.so`, `libplatform_linux.so`, `libgem.so`
- GEMix fonts and runtime resources in `/opt/gemix/share/gem`
- GEM tools in `/opt/gemix/bin`: `gemd` and `resgen`
- pkg-config entries for `gemix`, `gemix-aes`, `gemix-vdi`, `gemix-rasta`, `gemix-platform-linux`, and `gemix-gem`

`GEM_RESOURCE_DIR` defaults to `/opt/gemix/share/gem`; no separate runtime
resource mount is required.

Example:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-gemix:latest \
  bash -lc 'gcc -o app main.c $(pkg-config --cflags --libs gemix)'
```

## CONTRIBUTE

Contributions are welcome. Please open an issue or pull request:
<https://github.com/wischner/docker-toolchains>
