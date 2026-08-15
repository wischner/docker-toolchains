# Bundled libXaw source

`libXaw-1.0.16.tar.xz` is the complete tracked-source snapshot used to build
the original Athena widgets. It is bundled here because the upstream source
is not assumed to be reachable during future builds.

The adjacent `.sha256` file is verified by both `Makefile.toolchain` and the
Docker build before extraction.

To deliberately replace the snapshot from a local checkout, run:

```bash
make -C gcc-x86_64-linux-x11 -f Makefile.toolchain \
  refresh-libxaw LIBXAW_ROOT=/path/to/libxaw
```
