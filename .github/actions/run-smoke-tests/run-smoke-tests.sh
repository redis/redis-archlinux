#!/bin/bash
# Usage: run-smoke-tests.sh <package_dir>
# Runs as root in a fresh archlinux:base container, from the repo root.
set -euo pipefail

package_dir=${1:?package directory required}
tag=$(sed -n 's/^_tag=//p' PKGBUILD)
pkgver=${tag//-/}

pacman -Syu --noconfirm
pacman -U --noconfirm "$package_dir"/redis-"$pkgver"-*.pkg.tar.zst

installed=$(pacman -Q redis)
printf 'Installed: %s\n' "$installed"
if [[ $installed != "redis $pkgver-"* ]]; then
  printf 'Expected redis %s, got %s\n' "$pkgver" "$installed" >&2
  exit 1
fi

server_version=$(redis-server --version)
printf '%s\n' "$server_version"
# Pre-releases report an upstream development version (8.12-rc2 is 8.11.241),
# so only GA tags can be compared to the server's version string.
if [[ $tag =~ ^[0-9]+\.[0-9]+\.[0-9]+$ && $server_version != *" v=$tag "* ]]; then
  printf 'Expected redis-server v=%s\n' "$tag" >&2
  exit 1
fi

modules=/usr/lib/redis/modules
bash redis-smoke-test.sh /usr/bin/redis-server /usr/bin/redis-cli \
  "$modules/redisbloom.so" "$modules/redisearch.so" \
  "$modules/rejson.so" "$modules/redistimeseries.so"

# The packaged configuration alone must load the bundled modules
socket=$(mktemp -u /tmp/redis-packaged-conf.XXXXXX)
redis-server /etc/redis/redis.conf --port 0 --unixsocket "$socket" --save '' --daemonize yes
for (( attempt=0; attempt<100; attempt++ )); do
  [[ $(redis-cli -s "$socket" PING 2>/dev/null) == PONG ]] && break
  sleep 0.1
done
loaded=$(redis-cli -s "$socket" --raw -e MODULE LIST)
redis-cli -s "$socket" SHUTDOWN NOSAVE >/dev/null || true
for module in bf search ReJSON timeseries; do
  if ! grep -Fxq "$module" <<<"$loaded"; then
    printf 'Module %s is not loaded by /etc/redis/redis.conf\n' "$module" >&2
    exit 1
  fi
done
printf 'PASS: /etc/redis/redis.conf loads the bundled modules\n'
