#!/usr/bin/env bash
# Check: what the controller's service account may do with AppRequests.
set -uo pipefail

fail=0
as_ctl=(--as=system:serviceaccount:starfleet:apprequest-controller)
res=apprequests.platform.starfleet.io

expect() {
  local want="$1"; shift
  local got
  got="$(kubectl auth can-i "$@" "${as_ctl[@]}" 2>/dev/null || true)"
  if [ "$got" != "$want" ]; then
    echo "FAIL: can-i $* answered '$got', expected '$want'"
    fail=1
  fi
}

expect yes get "$res" -n outpost
expect yes list "$res" --all-namespaces
expect yes update "$res" --subresource=status -n outpost
expect no create "$res" -n outpost
expect no delete "$res" -n outpost

if [ "$fail" -eq 0 ]; then
  echo "PASS: the controller reads AppRequests and writes their status only"
fi
exit "$fail"
