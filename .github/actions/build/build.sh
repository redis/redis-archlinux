#!/bin/bash
# Runs as a non-root user in an archlinux:base-devel container, from the repo root.
set -euo pipefail

sudo pacman -Syu --noconfirm --needed namcap
makepkg --syncdeps --noconfirm

# namcap exits 0 whatever it finds, so its error lines are detected here.
# Warnings stay advisory.
report=$(namcap PKGBUILD ./*.pkg.tar.zst 2>&1)
printf '%s\n' "$report"
if grep -Eq '^Error:| E: ' <<<"$report"; then
  printf '::error::namcap reported errors\n' >&2
  exit 1
fi
