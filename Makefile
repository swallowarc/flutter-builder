# basic parameters
NAME            := swallowarc/flutter-builder
FLUTTER_VERSION := 3.47.1
REVISION        := $(shell git rev-parse --short HEAD)

# build parameters
DOCKER_USER ?= fake_suer
DOCKER_PASS ?= fake_pass

.PHONY: build push docker-login
build:
	docker buildx build \
      --platform linux/amd64,linux/arm64 \
      --build-arg FLUTTER_VERSION=$(FLUTTER_VERSION) \
      -t $(NAME):latest \
      -t $(NAME):$(FLUTTER_VERSION) \
      --push \
      -f Dockerfile .

push: docker-login
	docker push swallowarc/flutter-builder

docker-login:
	docker login -u $(DOCKER_USER) -p $(DOCKER_PASS)
