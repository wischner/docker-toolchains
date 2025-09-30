# =========================
# Generic Docker toolchains
# One folder = one image
# =========================

# Defaults (override on command line: make build-all ORG=me IMG_VER=1.0.1)
ORG     ?= wischner
IMG_VER ?= 1.0.2

# Any immediate subdir that has a Dockerfile is considered a toolchain
TOOLCHAINS := $(patsubst %/,%,$(dir $(wildcard */Dockerfile)))

# Helper to pass optional per-dir build args from <dir>/build.args (KEY=VAL per line)
define _args_for_dir
$(shell if [ -f $(1)/build.args ]; then \
  awk -F= 'NF>=2 && $$1 !~ /^[[:space:]]*#/ {gsub(/^[[:space:]]+|[[:space:]]+$$/,"",$$1); gsub(/^[[:space:]]+|[[:space:]]+$$/,"",$$2); printf "--build-arg %s=%s ",$$1,$$2}' $(1)/build.args; \
fi)
endef

.PHONY: help list build-all push-all clean $(TOOLCHAINS) build-% push-%

help:
	@echo "Targets:"
	@echo "  make list                 # list detected toolchains"
	@echo "  make build-all            # build all images (:latest and :$${IMG_VER})"
	@echo "  make push-all             # push all images (:latest and :$${IMG_VER})"
	@echo "  make build-<dir>          # build specific dir (e.g. build-sdcc-z80)"
	@echo "  make push-<dir>           # push specific dir (e.g. push-gcc-arm-none-eabi)"

list:
	@echo "ORG=$(ORG)  IMG_VER=$(IMG_VER)"
	@echo "Toolchains: $(TOOLCHAINS)"

build-all: $(addprefix build-,$(TOOLCHAINS))
push-all:  $(addprefix push-,$(TOOLCHAINS))

# Generic build rule:
# - Image name: $(ORG)/<dir>
# - Tags: :latest and :$(IMG_VER)
# - Always passes IMG_VERSION, plus <dir>/build.args if present
build-%:
	@echo "==> Building $(ORG)/$*:latest and :$(IMG_VER)"
	@ARGS="$$(printf "%s" '$(_args_for_dir $*)') --build-arg IMG_VERSION=$(IMG_VER)"; \
	set -e; \
	echo "    Context: ./$*"; \
	echo "    Args:    $$ARGS"; \
	docker build $$ARGS \
	  -t $(ORG)/$*:latest \
	  -t $(ORG)/$*:$(IMG_VER) \
	  ./$* ; \
	if [ -f "$*/Makefile.toolchain" ]; then \
	  echo "==> Post-build hook for $*"; \
	  $(MAKE) -C $* -f Makefile.toolchain build || true; \
	fi

# Generic push rule (ensures images exist & tags are present)
push-%:
	@set -e; \
	echo "==> Preparing to push $(ORG)/$*:latest and :$(IMG_VER)"; \
	# Ensure :latest exists; if not, build it
	if ! docker image inspect $(ORG)/$*:latest >/dev/null 2>&1; then \
	  echo "   Local image $(ORG)/$*:latest not found. Building..."; \
	  $(MAKE) build-$*; \
	fi; \
	# Ensure :$(IMG_VER) tag exists; if not, tag from :latest
	if ! docker image inspect $(ORG)/$*:$(IMG_VER) >/dev/null 2>&1; then \
	  echo "   Tag :$(IMG_VER) missing. Tagging from :latest..."; \
	  docker tag $(ORG)/$*:latest $(ORG)/$*:$(IMG_VER); \
	fi; \
	echo "==> Pushing $(ORG)/$*:latest"; \
	docker push $(ORG)/$*:latest; \
	echo "==> Pushing $(ORG)/$*:$(IMG_VER)"; \
	docker push $(ORG)/$*:$(IMG_VER)

clean:
	@echo "Pruning dangling images and builder cache..."
	@docker image prune -f >/dev/null || true
	@docker builder prune -f >/dev/null || true