#!/bin/bash
# Usage: fetch-redis-source.sh <release_tag>
# Runs on the runner, from the repo root. Milestone and internal tags publish no
# redis-full release archive, so this builds it with upstream's `make tarball`
# and leaves it next to the PKGBUILD, where makepkg uses it instead of downloading.
set -euo pipefail

tag=${1:?release tag required}
archive=redis-full-$tag.tar.gz
url=https://github.com/redis/redis/releases/download/$tag/$archive

status=$(curl --silent --show-error --location --head --output /dev/null --write-out '%{http_code}' "$url")
case $status in
  2*)
    printf 'Release archive exists: %s\n' "$url"
    exit 0
    ;;
  404)
    printf 'No release archive for %s, building %s with make tarball\n' "$tag" "$archive"
    ;;
  *)
    printf 'Unexpected HTTP status %s for %s\n' "$status" "$url" >&2
    exit 1
    ;;
esac

src=$(mktemp -d)
trap 'rm -rf "$src"' EXIT
git clone --quiet --depth 1 --branch "$tag" https://github.com/redis/redis "$src"
if [[ ! -f $src/scripts/tarball.sh ]]; then
  printf 'Redis %s has no scripts/tarball.sh, cannot build %s\n' "$tag" "$archive" >&2
  exit 1
fi
make -C "$src" tarball TAG="$tag" OUT_PATH="$PWD/$archive"
