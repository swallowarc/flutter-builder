#!/usr/bin/env sh
# Resolve a Flutter channel name ("stable" / "beta") to the exact release
# version currently on that channel, using Flutter's release feed.
# An exact version (e.g. "3.47.8") is passed through unchanged.
# Requires curl and jq.
set -eu

requested="${1:-stable}"
case "$requested" in
  stable|beta)
    version=$(curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json \
      | jq -r --arg ch "$requested" '
          .current_release[$ch] as $hash
          | .releases[] | select(.channel == $ch and .hash == $hash) | .version')
    ;;
  master|main|dev)
    echo "error: '$requested' has no release tags; pass an exact version instead" >&2
    exit 1
    ;;
  *)
    version="$requested"
    ;;
esac

[ -n "$version" ] || { echo "error: could not resolve '$requested'" >&2; exit 1; }

# The Dockerfile clones by tag, so fail early if the tag does not exist upstream.
git ls-remote --exit-code --tags https://github.com/flutter/flutter.git "refs/tags/${version}" >/dev/null \
  || { echo "error: tag '$version' not found in flutter/flutter" >&2; exit 1; }

echo "$version"
