#!/usr/bin/env bash
set -euo pipefail

registry="${ALIYUN_REGISTRY:?}"
namespace="${ALIYUN_NAMESPACE:?}"

regctl registry login "$registry" -u "$ALIYUN_USERNAME" -p "$ALIYUN_PASSWORD"

version="$(curl -fsSL \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/henrygd/beszel/releases/latest \
  | sed -n 's/.*"tag_name": *"v\?\([^"]*\)".*/\1/p')"

copy() {
  local src="$1" dest="$2"
  echo "sync $src -> $dest"
  regctl image copy \
    --platform linux/amd64 \
    --platform linux/arm64 \
    --platform linux/arm/v7 \
    "$src" "$dest"
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
