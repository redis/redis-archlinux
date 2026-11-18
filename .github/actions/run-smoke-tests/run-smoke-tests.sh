#!/bin/bash
# Usage: run-smoke-tests.sh <package_dir>
# Runs as root in a fresh archlinux:base container, from the repo root.
set -euo pipefail

package_dir=${1:?package directory required}

# The package is the source of its version. The checked out PKGBUILD is not,
# because unstable, custom and nightly runs build a recipe that is not committed.
packages=()
for package in "$package_dir"/redis-*.pkg.tar.zst; do
  [[ $package == */redis-debug-* ]] || packages+=("$package")
done
if (( ${#packages[@]} != 1 )); then
  printf 'Expected one redis package in %s, found: %s\n' "$package_dir" "${packages[*]}" >&2
  exit 1
fi
package=${packages[0]}

pacman -Syu --noconfirm
expected=$(pacman -Qp "$package")
pacman -U --noconfirm "$package"

installed=$(pacman -Q redis)
printf 'Installed: %s\n' "$installed"
if [[ $installed != "$expected" ]]; then
  printf 'Expected %s, got %s\n' "$expected" "$installed" >&2
  exit 1
fi

server_version=$(redis-server --version)
printf '%s\n' "$server_version"
# Pre-releases report an upstream development version (8.12-rc2 is 8.11.241),
# so only a GA pkgver can be compared to the server's version string.
pkgver=${expected#redis }
pkgver=${pkgver%-*}
if [[ $pkgver =~ ^[0-9]+\.[0-9]+\.[0-9]+$ && $server_version != *" v=$pkgver "* ]]; then
  printf 'Expected redis-server v=%s\n' "$pkgver" >&2
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
