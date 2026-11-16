#!/bin/bash
# Usage: check-pinned-deps.sh <redis_source_dir>
# Runs from the repo root. The PKGBUILD supplies these dependencies to the
# offline build, so each pinned version must be the one the Redis source declares.
set -euo pipefail

src=${1:?redis source directory required}
tag=$(sed -n 's/^_tag=//p' PKGBUILD)

search=modules/redisearch/src
svs=$search/deps/VectorSimilarity/deps/ScalableVectorSearch/cmake
git_tag='GIT_TAG[[:space:]]+v?\K[0-9][0-9.]*'
# PKGBUILD variable, file that declares it, grep -P pattern matching the version
pins=(
  "_boostver $search/build/boost/boost.cmake boost-\K[0-9.]+(?=/)"
  "_cpu_featuresver $search/deps/VectorSimilarity/cmake/cpu_features.cmake $git_tag"
  "_evever $svs/eve.cmake $git_tag"
  "_robinmapver $svs/robin-map.cmake $git_tag"
  "_fmtver $svs/fmt.cmake $git_tag"
  "_spdlogver $svs/spdlog.cmake $git_tag"
  "_tomlplusplusver $svs/toml.cmake $git_tag"
)

failed=0
for pin in "${pins[@]}"; do
  read -r var file pattern <<<"$pin"
  pinned=$(sed -n "s/^$var=//p" PKGBUILD)
  if [[ ! -f $src/$file ]]; then
    printf '::error::%s: Redis %s has no %s\n' "$var" "$tag" "$file"
    failed=1
    continue
  fi
  wanted=$(grep -oP "$pattern" "$src/$file" | sort -u || true)
  if [[ -z $wanted || $wanted == *$'\n'* ]]; then
    printf '::error::%s: expected one version in %s, found: %s\n' "$var" "$file" "${wanted//$'\n'/ }"
    failed=1
  elif [[ $wanted != "$pinned" ]]; then
    printf '::error::%s is %s, Redis %s needs %s\n' "$var" "$pinned" "$tag" "$wanted"
    failed=1
  else
    printf '%s %s matches %s\n' "$var" "$pinned" "$file"
  fi
done
exit "$failed"
