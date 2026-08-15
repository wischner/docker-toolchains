# GCC x86_64 GEMix toolchain

Ubuntu 22.04 based GCC toolchain for **GEMix (DRI GEM on Linux)** development.

Includes:

- GCC, G++, CMake, pkg-config, gdb, and the X11 base stack
- GEMix headers in `/usr/local/include`
- GEMix shared libraries in `/usr/local/lib`
- GEMix fonts and runtime resources in `/opt/gemix/share/gem`
- pkg-config entries for `gemix`, `gemix-aes`, `gemix-vdi`, `gemix-rasta`, and `gemix-platform-linux`

`GEM_RESOURCE_DIR` defaults to `/opt/gemix/share/gem`; no separate runtime
resource mount is required.

Example:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-gemix:latest \
  gcc -o app main.c $(pkg-config --cflags --libs gemix)
```
