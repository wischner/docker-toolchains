# XCC Z80 toolchain

Ubuntu-based Z80 development image that installs the published
large-model Linux bundle (`x-l-linux.zip`) from the
`retro-vault/xyz` GitHub release of the
[X Compiler Suite](https://quinzee.xyz/x).

Official project page: https://quinzee.xyz/x

Inside the image you get:

- `xcc` for full-model C23 compilation
- `xas` for assembly
- `xld` for linking
- `xopt` for post-generation assembly optimization
- `xar` for static libraries
- `xobjcopy` for object and archive conversion
- `xgdb` and `xemu` for source-level debugging, plus an `xgdb-z80` compatibility alias
- target headers and runtime in `/opt/x/z80/include` and `/opt/x/z80/lib`
- host-side SDK headers and libraries in `/opt/x/include` and `/opt/x/lib`

`/opt/x/bin` is already on `PATH`, so the tools are ready to use without extra
setup. `/opt/xtools` is also kept as a compatibility symlink to `/opt/x`.

## Run As Your User

Run the container as your active host user so generated files belong to you and
not to root:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xcc --version
```

All samples below use that same pattern.

## xcc

`xcc` is the main compiler driver. It preprocesses and compiles C, invokes
`xas` to assemble, and invokes `xld` to link.

Build a relocatable `XL` image:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xcc hello.c -o hello.xl
```

Compile only and keep the relocatable object:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xcc -c hello.c -o hello.rel
```

Build a flat binary at a fixed address:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xcc --oformat=binary -Ttext=0x8000 hello.c -o hello.bin
```

Build for the staged CP/M 3 runtime:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xcc --platform=cpm3 hello.c -o hello-cpm3.xl
```

## xas

`xas` assembles hand-written Z80 source. It accepts SDCC-style syntax by
default and can also work in GNU mode.

Assemble SDCC-style source into a `.rel` object:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xas startup.s -o startup.rel
```

Assemble with debug information:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xas -g main.s -o main.rel
```

Assemble GNU-style source into ELF:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xas --mode=gnu startup.s -o startup.o
```

## xld

`xld` links relocatable objects and libraries into final program images. It can
emit `XL`, flat binary, Intel HEX, and ELF outputs.

Link a normal Z80 program into an `XL` image:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xld main.rel util.rel -o app.xl
```

Link a fixed-address binary:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xld --oformat=binary -Ttext=0x8000 main.rel -o app.bin
```

Produce Intel HEX plus a memory map:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xld --oformat=ihx -Map=app.map main.rel -o app.ihx
```

## xopt

`xopt` optimizes generated or hand-written Z80 assembly. It is useful when you
want to inspect and tune assembly outside the normal `xcc` pipeline.

Optimize one assembly file into a new output:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xopt -O3 input.s -o output.s
```

Replace a generated assembly file in place:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xopt -Of --in-place generated.s
```

Print optimization statistics without writing output:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xopt --stats -O3 input.s
```

## xar

`xar` creates and manages static libraries of relocatable Z80 objects.

Create or update a library:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xar rcs libgame.a sprites.rel sound.rel
```

List the members of a library:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xar t libgame.a
```

Extract all members:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xar x libgame.a
```

## xobjcopy

`xobjcopy` converts objects and archives between supported formats and can strip
debug data from them.

Convert an SDCC `.rel` object to ELF:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xobjcopy -I rel -O elf main.rel main.o
```

Convert an ELF object back to `.rel`:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xobjcopy -I elf -O rel main.o main.rel
```

Strip debug information from an object:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xobjcopy --strip-debug main.rel main-stripped.rel
```

## xgdb and xemu

`xgdb` is the debugger frontend. Upstream `xemu` is the bundled remote target
and emulator that speaks the GDB remote protocol. For compatibility with older
image revisions, `xgdb-z80` is also available as an alias to `xemu`.

Build with debug information:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xcc -g hello.c -o hello.xl
```

Start the bundled Z80 debug target:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  -p 9000:9000 \
  wischner/xcc-z80:latest \
  xemu --listen 0.0.0.0:9000
```

Connect the debugger frontend to the running target:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work -w /work \
  wischner/xcc-z80:latest \
  xgdb --exec hello.xl --cdb hello.cdb --remote host.docker.internal:9000
```
