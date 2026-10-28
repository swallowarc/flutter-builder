# flutter-builder

Docker image for building Flutter **web** apps in CI.
Based on `ubuntu:24.04` with the Flutter SDK (web artifacts precached) and `git`, `curl`, `unzip`, `zip`, `xz-utils`, `make`.

Images are published to GitHub Container Registry:

```
ghcr.io/swallowarc/flutter-builder:<flutter version>   # e.g. 3.47.8
ghcr.io/swallowarc/flutter-builder:latest
```

## Usage

```sh
docker run --rm -v "$PWD:/app" ghcr.io/swallowarc/flutter-builder:latest \
  sh -c 'flutter pub get && flutter build web'
```

## Building a new image (GitHub Actions)

Run the **Build and push image** workflow from the Actions tab (`workflow_dispatch`).

| Input | Default | Description |
|---|---|---|
| `flutter_version` | `stable` | `stable` / `beta` resolves to the current release of that channel. An exact tag such as `3.47.8` is used as is. |
| `push_latest` | `true` | Also tag the image as `latest`. |
| `force` | `false` | Rebuild even if this version is already published. By default a published version is skipped. |

The workflow builds `linux/amd64` and `linux/arm64` on native runners and pushes a multi-arch manifest tagged with the resolved Flutter version.
Authentication uses the workflow's `GITHUB_TOKEN`; no secrets need to be configured.

## Building locally

```sh
make version                       # print the resolved Flutter version
make build-local                   # single-arch, loaded into local docker
make setup                         # once per host: register QEMU for cross-arch builds
make build                         # multi-arch, pushed to ghcr (needs `docker login ghcr.io`)
make build FLUTTER_CHANNEL=3.47.7  # exact version
make build FORCE=1                 # rebuild even if already published
```

## Notes

- The Dockerfile clones Flutter by **release tag**, not by channel branch.
  On a channel branch the Flutter tool fetches every upstream tag on first run, which adds about 450 MB to `.git` for nothing.
  Because of this, `flutter --version` inside the image reports `channel [user-branch]`; this does not affect builds.
- `flutter precache --web` is run at build time so `flutter build web` does not download the web SDK on every CI run.
