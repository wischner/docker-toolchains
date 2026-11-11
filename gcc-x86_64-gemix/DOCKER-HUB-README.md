# GCC x86_64 GEMix toolchain

**Support:** [wischner.co.uk/support](https://wischner.co.uk/support)

Ubuntu 22.04 based GCC toolchain for **GEMix (DRI GEM on Linux)** development.
The GEM SDK, bundled GEM programs, and Rasta viewer are built from GEM
release v1.0.4 (`755e3f0147c40af23215b5ef92f7ef7f1d3dc2e6`) during the image
build. That revision builds Rasta `5f1e1511e918e8b4dfa6f8b7a51272f66133ea0e`.
The [Native](https://github.com/wischner/native) C++ UI SDK release v1.0.5 (`3184fd615d67bb27cdacc09e6a30b4c0123fa891`) is built
against it for both GEMix backends. Image 1.5.3 adds the unified system
menu bar, movable desktop icons, Add to Desktop, file-type icons, bold Ted
Markdown headings and Stout desktop-size repaint fixes, with Native's
square GEM toolbar separators. It keeps the single-pixel compact window frame.

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

## Complete menus and protocol compatibility

Versions 1.5.1 and later include matching protocol-3 libgem/gemd and the Native menu
installation fix. Standard GEM menus support 256 objects and 256 strings,
including separators; labels over 63 bytes and malformed or oversized trees
are rejected rather than truncated. Failed Native installation retains the
previous menu and reports the status. Rebuild clients and restart gemd and
all clients together: protocol-2 binaries cannot use the new server.

The image build runs a real-server smoke test for 32, 33 and 49 strings,
65 and 256 objects, check/disable updates, removal and overflow rejection.
Both bundled Native SDK variants are rebuilt against the same GEM libraries.
The Native revision is the v1.0.5 release tag, packaged under that version;
the exact commit is recorded in metadata.

GEM tab bands default to 20 pixels. Native applications can use
`tab_view::set_tab_height(28)` for a per-control override, or pass
`std::nullopt` to restore the theme.
Selected bottom/right tabs retain their outline at the page join. Both
splitter orientations show three centered one-pixel grip dots, including
splitters whose panes are leaf controls such as lists or text editors.
