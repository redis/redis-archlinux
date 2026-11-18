#!/bin/bash
# Usage: fetch-redis-source.sh <redis_ref>
# Runs on the runner, from the repo root. Milestone and internal tags and
# branches publish no redis-full release archive, so this builds it with
# upstream's `make tarball` and leaves it next to the PKGBUILD, where makepkg
# uses it instead of downloading.
#
# REDISEARCH_VERSION, REDISJSON_VERSION, REDISBLOOM_VERSION and
# REDISTIMESERIES_VERSION, when set, replace the module ref that Redis pins.
# A release archive holds the pinned modules, so it is not used then.
set -euo pipefail

tag=${1:?redis ref required}
archive=redis-full-$tag.tar.gz
url=https://github.com/redis/redis/releases/download/$tag/$archive

declare -A module_refs=(
  [redisearch]=${REDISEARCH_VERSION:-}
  [redisjson]=${REDISJSON_VERSION:-}
  [redisbloom]=${REDISBLOOM_VERSION:-}
  [redistimeseries]=${REDISTIMESERIES_VERSION:-}
)
overrides=()
for module in "${!module_refs[@]}"; do
  [[ -z ${module_refs[$module]} ]] || overrides+=("$module=${module_refs[$module]}")
done

if (( ${#overrides[@]} )); then
  printf 'Building %s with make tarball, module refs: %s\n' "$archive" "${overrides[*]}"
else
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
fi

src=$(mktemp -d)
trap 'rm -rf "$src"' EXIT
git clone --quiet --depth 1 --branch "$tag" https://github.com/redis/redis "$src"
if [[ ! -f $src/scripts/tarball.sh ]]; then
  printf 'Redis %s has no scripts/tarball.sh, cannot build %s\n' "$tag" "$archive" >&2
  exit 1
fi

# modules.yaml is the manifest make tarball clones the modules from
manifest=$src/modules/modules.yaml
for override in "${overrides[@]}"; do
  module=${override%%=*}
  ref=${override#*=}
  awk -v module="$module" -v ref="$ref" '
    $1 == "-" && $2 == "name:" { current = $3 }
    $1 == "ref:" && current == module { sub(/ref:.*/, "ref: " ref); replaced = 1 }
    { print }
    END { exit !replaced }
  ' "$manifest" > "$manifest.new" || {
    printf 'Redis %s has no ref for module %s in modules/modules.yaml\n' "$tag" "$module" >&2
    exit 1
  }
  mv "$manifest.new" "$manifest"
done

make -C "$src" tarball TAG="$tag" OUT_PATH="$PWD/$archive"
