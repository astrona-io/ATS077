#!/usr/bin/env bash
# Check: what the group drifter-team may do with AppRequests.
set -uo pipefail

fail=0
as_team=(--as=casey --as-group=drifter-team)
res=apprequests.platform.starfleet.io

expect() {
  local want="$1"; shift
  local got
  got="$(kubectl auth can-i "$@" "${as_team[@]}" 2>/dev/null || true)"
  if [ "$got" != "$want" ]; then
    echo "FAIL: can-i $* answered '$got', expected '$want'"
    fail=1
  fi
}

expect yes create "$res" -n outpost
expect yes get "$res" -n outpost
expect no create "$res" -n starfleet
expect no update "$res" -n outpost
expect no delete "$res" -n outpost
expect no update "$res" --subresource=status -n outpost

if [ "$fail" -eq 0 ]; then
  echo "PASS: drifter-team can submit and read AppRequests in outpost and nothing more"
fi
exit "$fail"
