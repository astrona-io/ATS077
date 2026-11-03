#!/usr/bin/env bash
# Check: each team made its own choices on top of the same base.
set -uo pipefail

fail=0
check_team() {
  local ns="$1" want_replicas="$2" dep got
  dep="$(kubectl -n "$ns" get deployment web -o json 2>/dev/null || true)"
  if [ -z "$dep" ]; then
    echo "FAIL: deployment web does not exist in $ns"
    fail=1
    return
  fi
  got="$(jq -r '.spec.replicas // ""' <<<"$dep")"
  if [ "$got" != "$want_replicas" ]; then
    echo "FAIL: web in $ns has $got replicas, expected $want_replicas"
    fail=1
  fi
  got="$(jq -r '.metadata.labels.team // ""' <<<"$dep")"
  if [ "$got" != "$ns" ]; then
    echo "FAIL: Deployment web in $ns has team label '$got', expected '$ns'"
    fail=1
  fi
  got="$(jq -r '.spec.template.metadata.labels.team // ""' <<<"$dep")"
  if [ "$got" != "$ns" ]; then
    echo "FAIL: pod template of web in $ns has team label '$got', expected '$ns'"
    fail=1
  fi
  if ! kubectl -n "$ns" get service web >/dev/null 2>&1; then
    echo "FAIL: service web does not exist in $ns"
    fail=1
  fi
}

check_team bridge 2
check_team engine 1

if [ "$fail" -eq 0 ]; then
  echo "PASS: bridge runs 2 replicas, engine runs 1, both labelled by team with a Service"
fi
exit "$fail"
