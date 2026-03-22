# GCC x86_64 Haiku Cross-Toolchain

`wischner/gcc-x86_64-haiku` is a Docker image for **cross-compiling Haiku applications** from Linux to the `x86_64-unknown-haiku` target.

It includes a full Haiku-oriented cross-toolchain with sysroot, runtime libraries, development headers, and Jam, so it can build and link complete Haiku executables.
The image build automatically resolves and downloads the matching Haiku runtime
package pair (`haiku` + `haiku_devel`) from the EU mirror by default.

## What is included

- `x86_64-unknown-haiku-gcc` and `g++`
- Haiku-targeted binutils
- Haiku sysroot and runtime libraries
- Haiku development headers
- Haiku source tree for reference
- Jam build system
- build tools such as `git`, `python3`, `perl`, `cmake`, `make`, and `nasm`

## What this image is for

- cross-compiling Haiku applications from Linux
- C and C++ Haiku development
- Jam-based Haiku builds
- reproducible CI builds for Haiku targets

## Quick start

Interactive shell:

```bash
docker run --rm -it \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-haiku:latest \
  bash
```

Compile a Haiku executable:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-haiku:latest \
  x86_64-unknown-haiku-gcc hello.c -o hello
```

Build with Jam:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD":/work -w /work \
  wischner/gcc-x86_64-haiku:latest \
  jam
```

## C++ GUI Example (Cross-Compiled)

`hello.cpp`:

```cpp
#include <Application.h>
#include <Alert.h>
#include <String.h>

#include <stdio.h>

class HelloApp : public BApplication {
public:
    HelloApp() : BApplication("application/x-vnd.test-hello") {}

    void ReadyToRun() override {
        BAlert* alert = new BAlert(
            "Hello Haiku",
            "Hello from cross-compiled Haiku!\n\nBuilt with Docker on Linux.",
            "OK"
        );
        alert->Go();
        Quit();
    }
};

int main() {
    HelloApp app;
    app.Run();
    return 0;
}
```

`Makefile`:

```make
# Cross-compilation Makefile for Haiku
# Run `make docker` on Linux to build inside the wischner/gcc-x86_64-haiku container.
# Run `make` directly when already inside the container.

DOCKER_IMAGE = wischner/gcc-x86_64-haiku

# ---------------------------------------------------------------------------
# Toolchain
# ---------------------------------------------------------------------------
CXX      = x86_64-unknown-haiku-g++
CXXFLAGS = -std=c++17 -Wall -Wextra

# The Docker image sets HAIKU_SYSROOT; fall back for direct invocation.
HAIKU_TOOLCHAIN  ?= /opt/haiku-buildtools/build/cross-tools-x86_64
HAIKU_SYSROOT    ?= $(HAIKU_TOOLCHAIN)/sysroot
HAIKU_INCLUDE     = $(HAIKU_SYSROOT)/boot/system/develop/headers
HAIKU_LIB         = $(HAIKU_SYSROOT)/boot/system/develop/lib
HAIKU_CXXLIB      = $(HAIKU_TOOLCHAIN)/x86_64-unknown-haiku/lib

INCLUDES  = -I$(HAIKU_INCLUDE) \
            -I$(HAIKU_INCLUDE)/os \
            -I$(HAIKU_INCLUDE)/os/app \
            -I$(HAIKU_INCLUDE)/os/interface \
            -I$(HAIKU_INCLUDE)/os/support

LIBS      = -L$(HAIKU_LIB) -L$(HAIKU_CXXLIB) -lbe -lstdc++

# ---------------------------------------------------------------------------
# Build targets
# ---------------------------------------------------------------------------
TARGET  = hello
SRCS    = hello.cpp
OBJS    = $(SRCS:.cpp=.o)

.PHONY: all clean docker

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $^ $(LIBS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

clean:
	rm -f $(OBJS) $(TARGET)

# Build inside the Docker cross-compiler container.
docker:
	docker run --rm \
		--user $(shell id -u):$(shell id -g) \
		-v "$(CURDIR):/work" \
		-w /work \
		$(DOCKER_IMAGE) \
		make all
```

Build command:

```bash
make docker
```

## Environment

- `HAIKU_TOOLCHAIN_PATH=/opt/haiku-buildtools`
- `HAIKU_SOURCE=/opt/haiku-buildtools/haiku`
- `HAIKU_SYSROOT=/opt/haiku-buildtools/build/cross-tools-x86_64/sysroot`

## Support

Issues and pull requests are welcome:
<https://github.com/wischner/docker-toolchains>
