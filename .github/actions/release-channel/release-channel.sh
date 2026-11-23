#!/bin/bash
# Usage: release-channel.sh <release_tag> <release_type>
# Prints the channel of a release as key=value lines for GITHUB_OUTPUT.
set -euo pipefail

release_tag=${1:?release tag required}
release_type=${2:?release type required}

case $release_type in
  public)
    repo_name=redis
    s3_prefix=arch
    url_prefix=https://packages.redis.io/arch
    env_name=production
    ;;
  internal)
    repo_name=redis-testing
    s3_prefix=arch-testing
    url_prefix=https://redis-test-package-repository.s3.us-east-2.amazonaws.com/arch-testing
    env_name=staging
    ;;
  *)
    printf '::error::Invalid release_type: %s\n' "$release_type" >&2
    exit 1
    ;;
esac

# pacman upgrades every [redis] user to the newest pkgver, pre-releases included.
if [[ $release_type == public && ! $release_tag =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  printf '::error::Refusing to publish non-GA tag %s as a public release\n' "$release_tag" >&2
  exit 1
fi

printf '%s=%s\n' \
  repo_name "$repo_name" \
  s3_prefix "$s3_prefix" \
  url_prefix "$url_prefix" \
  env_name "$env_name"
