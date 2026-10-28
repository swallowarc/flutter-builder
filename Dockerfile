# Build Flutter Builder Container (web only)
FROM ubuntu:24.04

# Exact Flutter release tag to clone, e.g. "3.47.8".
# Resolve a channel name with scripts/resolve-flutter-version.sh first.
# Do NOT pass a channel name ("stable", "beta") here: on a channel branch the
# Flutter tool fetches every upstream tag on first run, which adds ~450 MB
# to .git. A tag checkout skips that fetch entirely.
ARG FLUTTER_VERSION=3.47.8
ARG FLUTTER_HOME=/usr/local/flutter

ENV DEBIAN_FRONTEND=noninteractive \
    PATH="${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:${PATH}"

WORKDIR /app

# One layer for apt: the lists are removed inside the same layer,
# otherwise they stay in the image even after rm -rf.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates git curl wget unzip zip xz-utils make \
 && rm -rf /var/lib/apt/lists/*

# No `flutter upgrade`: the clone is already at the requested release.
# `precache --web` downloads only the Dart SDK and web artifacts instead of
# every host artifact, so `flutter build web` needs no downloads at CI time.
RUN git clone https://github.com/flutter/flutter.git \
      -b "${FLUTTER_VERSION}" --depth 1 "${FLUTTER_HOME}" \
 && git config --system --add safe.directory "${FLUTTER_HOME}" \
 && flutter config --no-analytics --enable-web \
 && flutter precache --web \
 && flutter doctor -v
