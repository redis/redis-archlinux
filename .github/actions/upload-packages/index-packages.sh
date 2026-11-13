#!/bin/bash
# Usage: index-packages.sh <repo_name> <repo_dir>
# Signs every package in repo_dir with the default GPG key (or GPG_ID) and adds
# them to <repo_name>.db.tar.gz there, creating the database if it is missing.
# Afterwards repo_dir holds exactly the files to upload.
set -euo pipefail

repo_name=${1:?repo name required}
repo_dir=$(realpath -- "${2:?repo directory required}")

cd "$repo_dir"
packages=(*.pkg.tar.zst)
[[ -e ${packages[0]} ]]

for package in "${packages[@]}"; do
  gpg --batch --yes ${GPG_ID:+--local-user "$GPG_ID"} \
    --detach-sign --no-armor --output "$package.sig" "$package"
done

# repo-add runs without secrets; it embeds the .sig files next to each package.
docker run --rm --user "$(id -u):$(id -g)" -v "$repo_dir:/repo" -w /repo archlinux:base \
  repo-add --nocolor --prevent-downgrade "$repo_name.db.tar.gz" "${packages[@]}"

# S3 has no symlinks, so serve real copies under the names pacman requests.
for kind in db files; do
  cp --remove-destination "$repo_name.$kind.tar.gz" "$repo_name.$kind"
  rm -f "$repo_name.$kind.tar.gz.old"
done
