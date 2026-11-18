#!/bin/bash
# Usage: release-channel.sh <release_tag> <release_type> [run_type]
# Prints the channel of a release as key=value lines for GITHUB_OUTPUT.
set -euo pipefail

release_tag=${1:?release tag required}
release_type=${2:?release type required}
run_type=${3:-release}

case $run_type in
  release | unstable | custom | nightly) ;;
  *)
    printf '::error::Invalid run_type: %s\n' "$run_type" >&2
    exit 1
    ;;
esac

case $release_type in
  public)
    repo_name=redis
    secret_suffix=
    s3_prefix=arch
    url_prefix=https://packages.redis.io/arch
    env_name=production
    ;;
  internal)
    repo_name=redis-testing
    secret_suffix=_STAGING
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

# Only a release is built from a recipe that was committed and can be tagged.
if [[ $run_type != release && $release_type == public ]]; then
  printf '::error::Refusing a public release for run_type %s\n' "$run_type" >&2
  exit 1
fi

printf '%s=%s\n' \
  repo_name "$repo_name" \
  secret_suffix "$secret_suffix" \
  s3_prefix "$s3_prefix" \
  url_prefix "$url_prefix" \
  env_name "$env_name"
