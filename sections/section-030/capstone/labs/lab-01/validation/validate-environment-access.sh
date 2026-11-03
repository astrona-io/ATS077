#!/usr/bin/env bash
# Check: what the group drifter-team may do in each environment.
set -uo pipefail

fail=0
as_team=(--as=casey --as-group=drifter-team)

expect() {
  local want="$1"; shift
  local got
  got="$(kubectl auth can-i "$@" "${as_team[@]}" 2>/dev/null || true)"
  if [ "$got" != "$want" ]; then
    echo "FAIL: can-i $* answered '$got', expected '$want'"
    fail=1
  fi
}

expect yes create deployments.apps -n dev
expect yes create deployments.apps -n test
expect yes get pods -n prod
expect no create deployments.apps -n prod
expect no update deployments.apps -n prod
expect no get secrets -n prod

if [ "$fail" -eq 0 ]; then
  echo "PASS: drifter-team deploys in dev and test and only reads in prod"
fi
exit "$fail"
