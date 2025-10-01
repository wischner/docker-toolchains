# =========================
# Generic Docker toolchains
# One folder = one image
# =========================

ORG     ?= wischner
IMG_VER ?= 1.0.0

# Any immediate subdir that has a Dockerfile is considered a toolchain
TOOLCHAINS := $(patsubst %/,%,$(dir $(wildcard */Dockerfile)))

.PHONY: help list build-all push-all clean $(TOOLCHAINS) build-% push-% print-versions

help:
	@echo "Targets:"
	@echo "  make list                 # list detected toolchains"
	@echo "  make build-all            # build all images (:latest and :<per-image IMG_VERSION>)"
	@echo "  make push-all             # push all images (:latest and :<per-image IMG_VERSION>)"
	@echo "  make build-<dir>          # build specific dir"
	@echo "  make push-<dir>           # push specific dir"
	@echo "  make print-versions       # show effective versions per dir"

list:
	@echo "ORG=$(ORG)  IMG_VER(default)=$(IMG_VER)"
	@printf "Toolchains: %s\n" "$(TOOLCHAINS)"

print-versions:
	@set -e; \
	for d in $(TOOLCHAINS); do \
	  BVER=$$(awk -F= 'NF>=2 && $$1 !~ /^[[:space:]]*#/ {key=$$1; val=$$2; gsub(/^[[:space:]]+|[[:space:]]+$$/,"",key); gsub(/^[[:space:]]+|[[:space:]]+$$/,"",val); if (toupper(key)=="IMG_VERSION"){print val; exit}}' "$$d/build.args" 2>/dev/null || true); \
	  DVER=$$(awk 'BEGIN{IGNORECASE=1} /^[[:space:]]*ARG[[:space:]]+IMG_VERSION([[:space:]]*=[[:space:]]*[^[:space:]]+)?/ {match($$0,/=[[:space:]]*([^[:space:]]+)/,m); if(m[1]!=""){ver=m[1]; gsub(/^["'\''"]|["'\''"]$$/,"",ver); print ver; exit}}' "$$d/Dockerfile" 2>/dev/null || true); \
	  EFF=$${BVER:-$${DVER:-$(IMG_VER)}}; \
	  printf "%-28s build.args=%-10s Dockerfile=%-10s effective=%s\n" $$d "$$BVER" "$$DVER" "$$EFF"; \
	done

build-all: $(addprefix build-,$(TOOLCHAINS))
push-all:  $(addprefix push-,$(TOOLCHAINS))

# Build: tag :latest and :<effective version>, pass all build.args (except IMG_VERSION)
build-%:
	@set -e; \
	d="$*"; \
	echo "==> Building $(ORG)/$$d"; \
	BVER=$$(awk -F= 'NF>=2 && $$1 !~ /^[[:space:]]*#/ {key=$$1; val=$$2; gsub(/^[[:space:]]+|[[:space:]]+$$/,"",key); gsub(/^[[:space:]]+|[[:space:]]+$$/,"",val); if (toupper(key)=="IMG_VERSION"){print val; exit}}' "$$d/build.args" 2>/dev/null || true); \
	DVER=$$(awk 'BEGIN{IGNORECASE=1} /^[[:space:]]*ARG[[:space:]]+IMG_VERSION([[:space:]]*=[[:space:]]*[^[:space:]]+)?/ {match($$0,/=[[:space:]]*([^[:space:]]+)/,m); if(m[1]!=""){ver=m[1]; gsub(/^["'\''"]|["'\''"]$$/,"",ver); print ver; exit}}' "$$d/Dockerfile" 2>/dev/null || true); \
	EFF=$${BVER:-$${DVER:-$(IMG_VER)}}; \
	EXTRA_ARGS=$$(awk -F= 'NF>=2 && $$1 !~ /^[[:space:]]*#/ {key=$$1; val=$$2; gsub(/^[[:space:]]+|[[:space:]]+$$/,"",key); gsub(/^[[:space:]]+|[[:space:]]+$$/,"",val); if (toupper(key)!="IMG_VERSION") printf "--build-arg %s=%s ", key, val}' "$$d/build.args" 2>/dev/null); \
	ARGS="$$EXTRA_ARGS --build-arg IMG_VERSION=$$EFF"; \
	echo "    Context: ./$$d"; \
	echo "    Args:    $$ARGS"; \
	echo "    Tags:    latest, $$EFF"; \
	docker build $$ARGS -t $(ORG)/$$d:latest -t $(ORG)/$$d:$$EFF ./$$d ; \
	if [ -f "$$d/Makefile.toolchain" ]; then \
	  echo "==> Post-build hook for $$d"; \
	  $(MAKE) -C $$d -f Makefile.toolchain build || true; \
	fi

push-%:
	@set -e; \
	d="$*"; \
	BVER=$$(awk -F= 'NF>=2 && $$1 !~ /^[[:space:]]*#/ {key=$$1; val=$$2; gsub(/^[[:space:]]+|[[:space:]]+$$/,"",key); gsub(/^[[:space:]]+|[[:space:]]+$$/,"",val); if (toupper(key)=="IMG_VERSION"){print val; exit}}' "$$d/build.args" 2>/dev/null || true); \
	DVER=$$(awk 'BEGIN{IGNORECASE=1} /^[[:space:]]*ARG[[:space:]]+IMG_VERSION([[:space:]]*=[[:space:]]*[^[:space:]]+)?/ {match($$0,/=[[:space:]]*([^[:space:]]+)/,m); if(m[1]!=""){ver=m[1]; gsub(/^["'\''"]|["'\''"]$$/,"",ver); print ver; exit}}' "$$d/Dockerfile" 2>/dev/null || true); \
	EFF=$${BVER:-$${DVER:-$(IMG_VER)}}; \
	echo "==> Preparing to push $(ORG)/$$d:latest and :$$EFF"; \
	if ! docker image inspect $(ORG)/$$d:latest >/dev/null 2>&1; then \
	  echo "   Local image :latest not found. Building..."; \
	  $(MAKE) build-$$d; \
	fi; \
	if ! docker image inspect $(ORG)/$$d:$$EFF >/dev/null 2>&1; then \
	  echo "   Tag :$$EFF missing. Tagging from :latest..."; \
	  docker tag $(ORG)/$$d:latest $(ORG)/$$d:$$EFF; \
	fi; \
	echo "==> Pushing $(ORG)/$$d:latest"; docker push $(ORG)/$$d:latest; \
	echo "==> Pushing $(ORG)/$$d:$$EFF"; docker push $(ORG)/$$d:$$EFF

clean:
	@echo "Pruning dangling images and builder cache..."
	@docker image prune -f >/dev/null || true
	@docker builder prune -f >/dev/null || true
