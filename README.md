## Getting Started

This project is a docker build setting for Flutter builder.

## Usage

Run `make build` to detect the latest stable Flutter version and build/push a multi-arch image (amd64/arm64) to Docker Hub.
If the version is already published, the build is skipped. Requires `docker login` beforehand; on a new host, run `make setup` once to register the arm64 emulator.

