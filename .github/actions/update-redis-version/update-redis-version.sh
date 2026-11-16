#!/bin/bash
# Usage: update-redis-version.sh <release_tag>
# Runs as a non-root user in an archlinux:base-devel container, from the repo root.
set -euo pipefail

tag=${1:?release tag required}
if [[ ! $tag =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?(-[a-z]+[0-9]*)*$ ]]; then
  printf 'Unsupported release tag: %s\n' "$tag" >&2
  exit 1
fi
pkgver=${tag//-/}

current_pkgver=$(sed -n 's/^pkgver=//p' PKGBUILD)
sed -i -e "s/^pkgver=.*/pkgver=$pkgver/" -e "s/^_tag=.*/_tag=$tag/" PKGBUILD
if [[ $current_pkgver != "$pkgver" ]]; then
  sed -i 's/^pkgrel=.*/pkgrel=1/' PKGBUILD
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
archive=redis-full-$tag.tar.gz
if [[ ! -f $archive ]]; then
  curl --fail --silent --show-error --location --output "$work/$archive" \
    "https://github.com/redis/redis/releases/download/$tag/$archive"
  archive=$work/$archive
fi

# A dependency tarball is never expected to change behind the same URL. If one
# does (moved tag, regenerated GitHub archive, replaced asset), the release must
# stop so a person looks at it. updpkgsums is deliberately not used for that
# reason: it rewrites every checksum from whatever it downloads and would
# accept the change silently. Only the Redis archive is expected to be new on
# each release, so only its entry, the first one, is replaced. The dependency
# sums stay as committed and makepkg fails when one of them no longer matches.
sum=$(sha512sum "$archive" | cut -d' ' -f1)
sed -i "s/^sha512sums=('[0-9a-f]*'/sha512sums=('$sum'/" PKGBUILD
if ! grep -q "^sha512sums=('$sum'" PKGBUILD; then
  printf 'Could not update the first sha512sums entry in PKGBUILD\n' >&2
  exit 1
fi
makepkg --printsrcinfo > .SRCINFO

tar -xzf "$archive" -C "$work"
.github/actions/common/check-pinned-deps.sh "$work/redis-$tag"
