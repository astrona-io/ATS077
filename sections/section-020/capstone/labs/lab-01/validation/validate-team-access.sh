#!/usr/bin/env bash
# Check: what the group drifter-team may do, answered by the API server.
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

expect yes update deployments.apps -n outpost
expect yes create deployments.apps -n outpost
expect yes get pods -n outpost
expect no delete deployments.apps -n outpost
expect no get secrets -n outpost
expect no update deployments.apps -n starfleet

if [ "$fail" -eq 0 ]; then
  echo "PASS: drifter-team can deploy in outpost and nothing more"
fi
exit "$fail"
