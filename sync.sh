#!/usr/bin/env bash
set -euo pipefail

registry="${ALIYUN_REGISTRY:?}"
namespace="${ALIYUN_NAMESPACE:?}"

skopeo login -u "$ALIYUN_USERNAME" -p "$ALIYUN_PASSWORD" "$registry"

version="$(curl -fsSL https://api.github.com/repos/henrygd/beszel/releases/latest \
  | sed -n 's/.*"tag_name": *"v\?\([^"]*\)".*/\1/p')"

copy() {
  local src="$1" dest="$2"
  echo "sync $src -> $dest"
  skopeo copy --all "docker://$src" "docker://$dest"
}

copy "ghcr.io/henrygd/beszel/beszel:edge" \
  "$registry/$namespace/beszel:edge"
copy "ghcr.io/henrygd/beszel/beszel-agent:edge" \
  "$registry/$namespace/beszel-agent:edge"
copy "ghcr.io/henrygd/beszel/beszel-agent:alpine" \
  "$registry/$namespace/beszel-agent:alpine"

if [ -n "$version" ]; then
  copy "ghcr.io/henrygd/beszel/beszel:$version" \
    "$registry/$namespace/beszel:$version"
  copy "ghcr.io/henrygd/beszel/beszel-agent:$version" \
    "$registry/$namespace/beszel-agent:$version"
fi
