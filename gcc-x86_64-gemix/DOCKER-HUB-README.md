# GCC x86_64 GEMix toolchain

Ubuntu 22.04 based GCC toolchain for **GEMix (DRI GEM on Linux)** development.

Includes:

- GCC, G++, CMake, pkg-config, gdb, and the X11 base stack
- GEMix headers in `/usr/local/include`
- GEMix shared libraries in `/usr/local/lib`
- pkg-config entries for `gemix`, `gemix-aes`, `gemix-vdi`, `gemix-rasta`, and `gemix-platform-linux`

Example:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-gemix:latest \
  gcc -o app main.c $(pkg-config --cflags --libs gemix)
```
