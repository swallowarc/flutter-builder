# basic parameters
NAME          := swallowarc/flutter-builder
RELEASES_JSON := https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json

.PHONY: build setup

# QEMU(arm64エミュレータ)の登録。新規ホストで一度だけ実行する
setup:
	docker run --privileged --rm tonistiigi/binfmt --install arm64

# 最新stableのFlutterバージョンを判定し、未publishならマルチアーチビルドしてpushする
build:
	@set -e; \
	docker buildx inspect multiarch >/dev/null 2>&1 || \
	  docker buildx create --name multiarch --driver docker-container; \
	VERSION=$$(curl -fsSL $(RELEASES_JSON) | jq -r '.current_release.stable as $$h | .releases[] | select(.hash == $$h) | .version' | head -1); \
	test -n "$$VERSION"; \
	echo "Latest stable Flutter: $$VERSION"; \
	if docker manifest inspect $(NAME):$$VERSION >/dev/null 2>&1; then \
	  echo "$(NAME):$$VERSION is already published. Nothing to do."; \
	else \
	  docker buildx build --builder multiarch \
	    --platform linux/amd64,linux/arm64 \
	    --build-arg FLUTTER_VERSION=$$VERSION \
	    -t $(NAME):latest -t $(NAME):$$VERSION \
	    --push -f Dockerfile .; \
	fi
