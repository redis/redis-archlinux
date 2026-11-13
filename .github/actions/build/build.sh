#!/bin/bash
# Runs as a non-root user in an archlinux:base-devel container, from the repo root.
set -euo pipefail

sudo pacman -Syu --noconfirm --needed namcap
makepkg --syncdeps --noconfirm

namcap PKGBUILD || true
namcap ./*.pkg.tar.zst || true
