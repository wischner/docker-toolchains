# GCC x86_64 Linux Window Maker / WINGs Toolchain

`wischner/gcc-x86_64-linux-window-maker` is a complete Ubuntu 22.04 based
Docker image for native **Window Maker** and **WINGs** development.

## What is included

- everything from `wischner/gcc-x86_64-linux-x11`
- the pinned, patched `retro-vault/window-maker` source checkout
- shared and static WINGs, WUtil, wraster, and WMaker SDK libraries
- all public/private development headers, pkg-config modules, and CMake targets
- Window Maker, WPrefs, wmagnify, wmiv, utilities, and development examples
- all menus, styles, themes, icons, artwork, defaults, translations, and manuals
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

## Support

Issues and pull requests are welcome:
<https://github.com/wischner/docker-toolchains>

