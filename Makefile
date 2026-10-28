# basic parameters
NAME     := ghcr.io/swallowarc/flutter-builder
REVISION := $(shell git rev-parse --short HEAD)

# build parameters
# "stable" / "beta" is resolved to the current release of that channel;
# an exact tag such as "3.47.8" is used as is.
FLUTTER_CHANNEL ?= stable
FLUTTER_VERSION := $(shell ./scripts/resolve-flutter-version.sh $(FLUTTER_CHANNEL))
PLATFORMS       ?= linux/amd64,linux/arm64

.PHONY: build build-local version setup

version:
	@echo $(FLUTTER_VERSION)

# QEMU (cross-arch emulator) registration. Run once on a new host before `make build`.
setup:
	docker run --privileged --rm tonistiigi/binfmt --install all

# Multi-arch build pushed to the registry (same tags as the GitHub Actions workflow).
# Skipped when this version is already published; set FORCE=1 to rebuild.
# Requires `docker login ghcr.io` beforehand.
build:
	@if [ -z "$(FORCE)" ] && docker manifest inspect $(NAME):$(FLUTTER_VERSION) >/dev/null 2>&1; then \
	  echo "$(NAME):$(FLUTTER_VERSION) is already published. Nothing to do (FORCE=1 to rebuild)."; \
	else \
	  docker buildx build \
	    --platform $(PLATFORMS) \
	    --build-arg FLUTTER_VERSION=$(FLUTTER_VERSION) \
	    -t $(NAME):$(FLUTTER_VERSION) \
	    -t $(NAME):latest \
	    --push \
	    -f Dockerfile . ; \
	fi

# Single-arch build loaded into the local docker daemon, for testing.
build-local:
	docker buildx build \
	  --build-arg FLUTTER_VERSION=$(FLUTTER_VERSION) \
	  -t $(NAME):$(FLUTTER_VERSION) \
	  --load \
	  -f Dockerfile .
