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

sudo pacman -Syu --noconfirm --needed pacman-contrib
SRCDEST=$(mktemp -d) updpkgsums
makepkg --printsrcinfo > .SRCINFO
