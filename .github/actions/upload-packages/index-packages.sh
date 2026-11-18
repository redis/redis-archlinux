#!/bin/bash
# Usage: index-packages.sh <repo_name> <repo_dir>
# Signs every package in repo_dir and adds them to <repo_name>.db.tar.gz there,
# creating the database if it is missing. With KMS_KEY_ID set, AWS KMS signs
# and the signatures verify with KMS_PUBLIC_KEY, a public key file. Otherwise
# the default GPG key (or GPG_ID) signs.
# Afterwards repo_dir holds exactly the files to upload.
set -euo pipefail

repo_name=${1:?repo name required}
repo_dir=$(realpath -- "${2:?repo directory required}")
script_dir=$(realpath -- "$(dirname -- "$0")")
[[ -z ${KMS_PUBLIC_KEY:-} ]] || KMS_PUBLIC_KEY=$(realpath -- "$KMS_PUBLIC_KEY")

cd "$repo_dir"
packages=(*.pkg.tar.zst)
[[ -e ${packages[0]} ]]

if [[ -n ${KMS_KEY_ID:-} ]]; then
  "$script_dir/kms-sign.py" "$KMS_KEY_ID" "${KMS_PUBLIC_KEY:?}" "${packages[@]}"
else
  for package in "${packages[@]}"; do
    gpg --batch --yes ${GPG_ID:+--local-user "$GPG_ID"} \
      --detach-sign --no-armor --output "$package.sig" "$package"
  done
fi

# repo-add needs pacman tooling but no secrets, so only this step runs in the Arch container.
docker run --rm --user "$(id -u):$(id -g)" -v "$repo_dir:/repo" -w /repo archlinux:base \
  repo-add --nocolor "$repo_name.db.tar.gz" "${packages[@]}"

# S3 has no symlinks, so serve real copies under the names pacman requests.
for kind in db files; do
  cp --remove-destination "$repo_name.$kind.tar.gz" "$repo_name.$kind"
  rm -f "$repo_name.$kind.tar.gz.old"
done
