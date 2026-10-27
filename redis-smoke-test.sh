#!/usr/bin/env bash
set -euo pipefail

if (( $# != 6 )); then
  printf 'Usage: %s redis-server redis-cli bloom.so search.so json.so timeseries.so\n' "$0" >&2
  exit 2
fi

server=$(realpath -- "$1")
client=$(realpath -- "$2")
shift 2
[[ -x "$server" && -x "$client" ]]
module_args=()
for module in "$@"; do
  module=$(realpath -- "$module")
  [[ -f "$module" ]]
  module_args+=(--loadmodule "$module")
done

workdir=$(mktemp -d /tmp/redis-smoke.XXXXXX)
socket=$workdir/redis.sock
server_pid=

cli() {
  timeout 5 "$client" --raw -e -s "$socket" "$@"
}

# Invoked indirectly by the EXIT trap.
# shellcheck disable=SC2329
cleanup() {
  local status=$?
  trap - EXIT
  if [[ -n "$server_pid" ]]; then
    cli SHUTDOWN NOSAVE >/dev/null 2>&1 || kill "$server_pid" 2>/dev/null || true
    wait "$server_pid" 2>/dev/null || true
  fi
  if (( status != 0 )); then
    cat "$workdir/server.log" >&2
  fi
  rm -rf -- "$workdir"
  exit "$status"
}
trap 'cleanup' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

"$server" --port 0 --unixsocket "$socket" --unixsocketperm 700 \
  --dir "$workdir" --save '' --appendonly no --daemonize no --repl-compression 1 \
  "${module_args[@]}" > "$workdir/server.log" 2>&1 &
server_pid=$!

ready=0
for (( attempt=0; attempt<100; attempt++ )); do
  if [[ $(cli PING 2>/dev/null) == PONG ]]; then
    ready=1
    break
  fi
  kill -0 "$server_pid" 2>/dev/null || break
  sleep 0.1
done
if (( ! ready )); then
  printf 'Redis did not become ready.\n' >&2
  exit 1
fi

expect() {
  local expected=$1 actual
  shift
  actual=$(cli "$@") || {
    printf '%s failed: %s\n' "$1" "$actual" >&2
    return 1
  }
  if [[ "$actual" != "$expected" ]]; then
    printf '%s: expected %q, got %q\n' "$1" "$expected" "$actual" >&2
    return 1
  fi
}

modules=$(cli MODULE LIST)
for module in bf search ReJSON timeseries; do
  grep -Fxq "$module" <<< "$modules"
done

expect OK CONFIG SET activedefrag yes
expect $'activedefrag\nyes' CONFIG GET activedefrag
expect OK CONFIG SET activedefrag no
expect $'repl-compression\n1' CONFIG GET repl-compression
expect OK JSON.SET smoke:json '$' '{"value":42}'
expect '[42]' JSON.GET smoke:json '$.value'
expect 1 BF.ADD smoke:bloom redis
expect 1 BF.EXISTS smoke:bloom redis
expect 0 BF.EXISTS smoke:bloom missing
expect OK TS.CREATE smoke:timeseries
expect 1 TS.ADD smoke:timeseries 1 42
expect $'1\n42' TS.GET smoke:timeseries
expect OK FT.CREATE smoke:index ON HASH PREFIX 1 smoke:doc: SCHEMA title TEXT
expect 1 HSET smoke:doc:1 title redis

for (( attempt=0; attempt<50; attempt++ )); do
  result=$(cli FT.SEARCH smoke:index redis NOCONTENT)
  if [[ "$result" == $'1\nsmoke:doc:1' ]]; then
    printf 'PASS: active defrag, compression, JSON, Bloom, TimeSeries, and Search\n'
    exit 0
  fi
  sleep 0.1
done
printf 'Search did not return the indexed document: %q\n' "$result" >&2
exit 1
