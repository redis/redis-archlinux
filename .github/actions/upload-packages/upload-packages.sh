#!/bin/bash
# Usage: upload-packages.sh <repo_dir>
# Environment: REPO_NAME, RELEASE_TYPE, S3_BUCKET, S3_PREFIX and AWS credentials.
# repo_dir holds the new packages; the existing index is fetched into it.
set -euo pipefail

repo_dir=${1:?repo directory required}
: "${REPO_NAME:?}" "${RELEASE_TYPE:?}" "${S3_BUCKET:?}" "${S3_PREFIX:?}"
remote="s3://$S3_BUCKET/$S3_PREFIX/x86_64"

packages=()
for package in "$repo_dir"/*.pkg.tar.zst; do
  packages+=("${package##*/}")
done

# A failed listing must stop the run: treating it as empty would publish an
# index that only contains this release.
listing=$(aws s3api list-objects-v2 --bucket "$S3_BUCKET" --prefix "$S3_PREFIX/x86_64/" \
  --query 'Contents[].Key' --output json)
existing=$(jq -r '.[]? | sub(".*/"; "")' <<< "$listing")
exists() {
  grep -Fxq -- "$1" <<< "$existing"
}

if [[ $RELEASE_TYPE == public ]]; then
  for package in "${packages[@]}"; do
    if exists "$package"; then
      printf '::error::%s already exists in %s\n' "$package" "$remote" >&2
      exit 1
    fi
  done
fi

for index in "$REPO_NAME.db.tar.gz" "$REPO_NAME.files.tar.gz"; do
  if exists "$index"; then
    aws s3 cp --no-progress "$remote/$index" "$repo_dir/$index"
  fi
done

"$(dirname -- "$0")/index-packages.sh" "$REPO_NAME" "$repo_dir"

upload() {
  aws s3 cp --no-progress --acl public-read "$repo_dir/$1" "$remote/$1"
}
for package in "${packages[@]}"; do
  upload "$package"
  upload "$package.sig"
done
# The index goes last so it never lists a package that is not uploaded yet.
for index in files.tar.gz files db.tar.gz db; do
  upload "$REPO_NAME.$index"
done
