# GCC x86_64 Linux Window Maker / WINGs Toolchain

**Support:** [wischner.co.uk/support](https://wischner.co.uk/support)

`wischner/gcc-x86_64-linux-window-maker` is a complete Ubuntu 22.04 based
Docker image for native **Window Maker** and **WINGs** development.

## What is included

- everything from `wischner/gcc-x86_64-linux-x11`
- the pinned, patched `retro-vault/window-maker` source checkout
- shared and static WINGs, WUtil, wraster, and WMaker SDK libraries
- all public/private development headers, pkg-config modules, and CMake targets
- Window Maker, WPrefs, wmagnify, wmiv, utilities, and development examples
- every menu, style, theme, icon, background, pixmap, artwork file, default,
  translation, and manual from the pinned source tree
- all optional image, text, EXIF, and X extension development dependencies
- Xvfb, Xephyr, xterm, and `window-maker-xephyr` for contained GUI testing

## Quick start

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-window-maker:latest \
  bash -lc 'gcc -o app app.c $(pkg-config --cflags --libs WINGs)'
```

CMake consumers can call `find_package(WindowMaker CONFIG REQUIRED)` and link
`WindowMaker::WINGs`; matching `_static` targets are also supplied.

Run a GUI in a self-contained Window Maker session:

```bash
docker run --rm \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-linux-window-maker:latest \
  window-maker-xephyr ./app
```

The source used to build the image remains available through
`$WINDOW_MAKER_SOURCE` (`/usr/local/src/window-maker`).

## CONTRIBUTE

Contributions are welcome. Please open an issue or pull request:
<https://github.com/wischner/docker-toolchains>

## Native C++ SDK

Image `1.5.0` includes [Native v1.1.0](https://github.com/wischner/native/releases/tag/v1.1.0)
for `linux-wmaker-x86_64` in `/opt/native/linux-wmaker-x86_64` (`$NATIVE_SDK`).
The release archive is SHA-256 pinned and includes `libnative.a`, public headers,
dependency libraries, `manifest.json`, licenses, and the `Native::Native` CMake target.
The image build compiles and links a consumer against this installed SDK.

Configure consumers with `-DNative_DIR="$NATIVE_SDK/lib/cmake/Native"`, then
use `find_package(Native CONFIG REQUIRED)` and link `Native::Native`.
