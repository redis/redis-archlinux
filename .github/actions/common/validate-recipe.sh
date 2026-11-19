#!/bin/bash
# Usage: validate-recipe.sh
# Runs from the repo root. Checks that every source matches its checksum in the
# PKGBUILD and that .SRCINFO is current. Outside Arch Linux it runs itself in
# an archlinux:base-devel container.
set -euo pipefail

if ! command -v makepkg >/dev/null; then
  exec docker run --rm -v "$PWD:/work" -w /work archlinux:base-devel \
    .github/actions/common/as-builder.sh "$0"
fi

# Keep the downloads out of the working tree
SRCDEST=$(mktemp -d)
export SRCDEST
makepkg --verifysource

if ! makepkg --printsrcinfo | diff .SRCINFO -; then
  printf '::error::.SRCINFO is stale, regenerate it with makepkg --printsrcinfo > .SRCINFO\n' >&2
  exit 1
fi
