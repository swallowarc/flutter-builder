# basic parameters
NAME     := swallowarc/flutter-builder
VERSION  := v0.0.0
REVISION := $(shell git rev-parse --short HEAD)

# build parameters
DOCKER_USER ?= fake_suer
DOCKER_PASS ?= fake_pass

.PHONY: build push docker-login
build:
	docker buildx build \
      --platform linux/amd64,linux/arm64 \
      -t swallowarc/flutter-builder:latest \
      --push \
      -f Dockerfile .

push: docker-login
	docker push swallowarc/flutter-builder

docker-login:
	docker login -u $(DOCKER_USER) -p $(DOCKER_PASS)
