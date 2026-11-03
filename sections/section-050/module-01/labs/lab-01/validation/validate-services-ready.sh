#!/usr/bin/env bash
# Check: every replica behind the Service web is ready. Waits up to 90 seconds.
set -uo pipefail

want_for() {
  case "$1" in
    bridge) echo 2 ;;
    engine) echo 1 ;;
  esac
}

fail=0
for ns in bridge engine; do
  want="$(want_for "$ns")"
  ready=0
  for _ in $(seq 1 45); do
    ready="$(kubectl -n "$ns" get endpointslices -l kubernetes.io/service-name=web -o json 2>/dev/null \
      | jq '[.items[].endpoints[]? | select(.conditions.ready == true)] | length' 2>/dev/null || echo 0)"
    [ "${ready:-0}" = "$want" ] && break
    sleep 2
  done
  if [ "${ready:-0}" != "$want" ]; then
    echo "FAIL: service web in $ns has $ready ready endpoints, expected $want"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: service web has one ready endpoint per replica in bridge and engine"
fi
exit "$fail"
