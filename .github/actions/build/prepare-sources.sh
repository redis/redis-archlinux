#!/bin/bash
# Runs as a non-root user in an archlinux:base-devel container, from the repo root.
# Everything that needs the network happens here: build dependencies, namcap,
# source downloads and prepare(). build.sh then runs with the network cut.
set -euo pipefail

sudo pacman -Syu --noconfirm --needed namcap
makepkg --nobuild --syncdeps --noconfirm
