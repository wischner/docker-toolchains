# GDB 17.1 Haiku Port — Change Log

## Bug Fixes

### Fix 1: Single-step always uses hardware breakpoints (`gdbserver/haiku-low.h`)

**Symptom:** Every `step` command in GDB forced a hardware debug-register breakpoint
instead of using the CPU's hardware single-step (Trap Flag) mechanism.

**Root cause:** `haiku_process_target` did not override `supports_hardware_single_step()`.
The base class default returns `false`. When a modern GDB client connects, it sends the
`vContSupported` feature flag, and gdbserver only advertises single-step support in its
`vCont?` reply when at least one of `supports_hardware_single_step()` or
`supports_software_single_step()` returns `true`. Since neither did, GDB fell back to
emulating single-step by inserting a `bp_hp_step_resume` breakpoint — which maps to a
hardware debug-register breakpoint on x86.

The Haiku gdbserver already implemented single-step correctly all along: `haiku_nat::resume()`
sends `B_DEBUG_MESSAGE_CONTINUE_THREAD` with `single_step = true`. It just never told GDB
it could do this.

**Fix:** Added to `haiku_process_target` in `gdbserver/haiku-low.h`:
```cpp
bool supports_hardware_single_step () override { return true; }
```

---

### Fix 2: Resume loop ignores all but the first action (`gdbserver/haiku-low.cc`)

**Symptom:** Multi-threaded programs hang or behave incorrectly during single-step.

**Root cause:** In `haiku_process_target::resume()`, the `for` loop iterates `i` from
0 to `n-1` but the `resume_info` pointer is never advanced — every iteration reads
`resume_info[0]`. GDB commonly sends compound `vCont` packets with multiple actions,
e.g. *step thread A, continue all others* (`n == 2`). Only the first action was ever
processed; the rest were silently dropped.

**Fix:** Changed all `resume_info->` accesses inside the loop to `resume_info[i].` in
`gdbserver/haiku-low.cc`.

---

### Fix 3: Build fix — renamed Haiku debugger API constants (`gdb/nat/haiku-nub-message.h`)

**Symptom:** Compilation failure against current Haiku headers:
```
error: 'B_DEBUG_START_PROFILER' was not declared in this scope
```

**Root cause:** Three `debug_nub_message` enum constants were renamed in a recent Haiku
revision. The GDB source used the old names.

**Fix:** Updated `gdb/nat/haiku-nub-message.h` to use the new names:

| Old name | New name |
|---|---|
| `B_DEBUG_START_PROFILER` | `B_DEBUG_MESSAGE_START_PROFILER` |
| `B_DEBUG_STOP_PROFILER` | `B_DEBUG_MESSAGE_STOP_PROFILER` |
| `B_DEBUG_WRITE_CORE_FILE` | `B_DEBUG_MESSAGE_WRITE_CORE_FILE` |

---

## Building

The source tree is a standard GNU autotools project. It must be cross-compiled for Haiku
using the `wischner/gcc-x86_64-haiku` Docker image, which provides the Haiku cross-toolchain
and sysroot.

The sysroot in that image contains only core Haiku libraries. The following dependencies
must be cross-compiled first and are not present in the image:

| Library | Version | Notes |
|---|---|---|
| GMP | 6.3.0 | `--disable-assembly` required (Haiku uses PIE executables) |
| MPFR | 4.2.1 | |
| zlib | 1.3.1 | |
| ncurses | 6.4 | widec build |
| readline | 8.2 | |
| expat | 2.6.2 | |
| xxhash | 0.8.2 | |

All static libraries must be compiled with `-fPIC` because Haiku x86_64 links executables
as position-independent (PIE). Libtool `.la` files must be removed after installation to
prevent libtool from mangling library paths at GDB link time.

**GDB configure flags used:**
```
--host=x86_64-unknown-haiku
--target=x86_64-unknown-haiku
--with-sysroot=$HAIKU_SYSROOT
--prefix=/boot/system
--disable-nls
--enable-gdb
--enable-gdbserver
--without-python
--with-expat
--with-system-zlib
--with-gmp=/staging
--with-mpfr=/staging
--with-readline=/staging
--disable-tui
```

Pre-built binaries (unstripped, x86-64 Haiku ELF) are in the `binaries/` directory.

### Docker build command

Run from the directory containing `gdb-17.1/`:

```bash
docker run --rm \
  -v "$(pwd)/gdb-17.1:/src:ro" \
  -v "$(pwd)/binaries:/output" \
  wischner/gcc-x86_64-haiku:1.0.0 bash -c '
    set -e
    SYSROOT=$HAIKU_SYSROOT
    CROSS=x86_64-unknown-haiku
    STAGING=/staging
    JOBS=$(nproc)
    export CC=$CROSS-gcc CXX=$CROSS-g++ AR=$CROSS-ar RANLIB=$CROSS-ranlib STRIP=$CROSS-strip NM=$CROSS-nm
    mkdir -p $STAGING
    cd /tmp

    # GMP
    curl -fL https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz | tar xJ
    mkdir build-gmp && cd build-gmp
    ../gmp-6.3.0/configure --host=$CROSS --prefix=$STAGING --with-sysroot=$SYSROOT \
        --disable-shared --enable-static --enable-cxx --disable-assembly \
        CFLAGS="-fPIC" CXXFLAGS="-fPIC"
    make -j$JOBS && make install && rm -f $STAGING/lib/libgmp.la $STAGING/lib/libgmpxx.la
    cd /tmp

    # MPFR
    curl -fL https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.1.tar.xz | tar xJ
    mkdir build-mpfr && cd build-mpfr
    ../mpfr-4.2.1/configure --host=$CROSS --prefix=$STAGING --with-sysroot=$SYSROOT \
        --with-gmp=$STAGING --disable-shared --enable-static CFLAGS="-fPIC"
    make -j$JOBS && make install && rm -f $STAGING/lib/libmpfr.la
    cd /tmp

    # zlib
    curl -fL https://zlib.net/fossils/zlib-1.3.1.tar.gz | tar xz
    cd zlib-1.3.1 && CHOST=$CROSS CFLAGS="-fPIC" ./configure --prefix=$STAGING --static
    make -j$JOBS && make install && cd /tmp

    # ncurses
    curl -fL https://ftp.gnu.org/gnu/ncurses/ncurses-6.4.tar.gz | tar xz
    mkdir build-ncurses && cd build-ncurses
    ../ncurses-6.4/configure --host=$CROSS --prefix=$STAGING --with-sysroot=$SYSROOT \
        --without-shared --with-static --without-debug --without-ada --without-tests \
        --enable-widec \
        --with-default-terminfo-dir=/boot/system/data/terminfo \
        --with-terminfo-dirs=/boot/system/data/terminfo \
        CFLAGS="-fPIC" CXXFLAGS="-fPIC"
    make -j$JOBS && make install
    for lib in $STAGING/lib/libncursesw.a; do
        base=$(basename $lib w.a).a
        [ ! -f $STAGING/lib/$base ] && ln -s $lib $STAGING/lib/$base
    done
    cp -n $STAGING/include/ncursesw/*.h $STAGING/include/ 2>/dev/null || true
    cd /tmp

    # readline
    curl -fL https://ftp.gnu.org/gnu/readline/readline-8.2.tar.gz | tar xz
    mkdir build-readline && cd build-readline
    CFLAGS="--sysroot=$SYSROOT -I$STAGING/include -fPIC" \
    LDFLAGS="--sysroot=$SYSROOT -L$STAGING/lib" \
    ../readline-8.2/configure --host=$CROSS --prefix=$STAGING \
        --with-sysroot=$SYSROOT --disable-shared --enable-static
    make -j$JOBS && make install && rm -f $STAGING/lib/libreadline.la $STAGING/lib/libhistory.la
    cd /tmp

    # expat
    curl -fL https://github.com/libexpat/libexpat/releases/download/R_2_6_2/expat-2.6.2.tar.gz | tar xz
    mkdir build-expat && cd build-expat
    ../expat-2.6.2/configure --host=$CROSS --prefix=$STAGING --with-sysroot=$SYSROOT \
        --disable-shared --enable-static --without-docbook --without-examples --without-tests \
        CFLAGS="-fPIC"
    make -j$JOBS && make install && rm -f $STAGING/lib/libexpat.la
    cd /tmp

    # xxhash
    curl -fL https://github.com/Cyan4973/xxHash/archive/refs/tags/v0.8.2.tar.gz | tar xz
    cd xxHash-0.8.2
    $CC --sysroot=$SYSROOT -O2 -fPIC -DXXH_STATIC_LINKING_ONLY -DXXH_IMPLEMENTATION \
        -c -x c xxhash.h -o xxhash.o
    $CROSS-ar rcs $STAGING/lib/libxxhash.a xxhash.o
    install -m644 xxhash.h $STAGING/include/
    cd /tmp

    # GDB
    mkdir /build && cd /build
    export CPPFLAGS="-DB_USE_POSITIVE_POSIX_ERRORS -I$STAGING/include"
    export CFLAGS="--sysroot=$SYSROOT -I$STAGING/include"
    export CXXFLAGS="--sysroot=$SYSROOT -I$STAGING/include"
    export LDFLAGS="--sysroot=$SYSROOT -L$STAGING/lib"
    /src/configure \
        --host=$CROSS --target=$CROSS --with-sysroot=$SYSROOT \
        --prefix=/boot/system --disable-nls \
        --enable-gdb --enable-gdbserver \
        --without-python --with-expat --with-libexpat-prefix=$STAGING \
        --with-system-zlib --with-gmp=$STAGING --with-mpfr=$STAGING \
        --with-readline=$STAGING --disable-tui
    make -j$JOBS
    cp /build/gdb/gdb /output/gdb
    cp /build/gdbserver/gdbserver /output/gdbserver
    echo "Done. Binaries in /output."
  '
```

The compiled binaries are written to the `binaries/` directory next to `gdb-17.1/`.
