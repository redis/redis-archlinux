#!/bin/bash
# Run a command inside an Arch container as an unprivileged user that owns the
# mounted workspace, because makepkg refuses to run as root.
set -euo pipefail

if ! id builder >/dev/null 2>&1; then
  useradd --create-home --uid "$(stat -c %u .)" builder
  printf 'builder ALL=(ALL) NOPASSWD: ALL\n' > /etc/sudoers.d/builder
fi
exec sudo -H -u builder -- "$@"
