#!/usr/bin/env bash
# Check: scout-request exists and was marked Accepted through the status endpoint.
set -uo pipefail

apr="$(kubectl -n starfleet get apprequest scout-request -o json 2>/dev/null || true)"
if [ -z "$apr" ]; then
  echo "FAIL: AppRequest scout-request does not exist in starfleet"
  exit 1
fi

fail=0
chk() {
  local label="$1" want="$2" filter="$3" got
  got="$(jq -r "$filter" <<<"$apr")"
  if [ "$got" != "$want" ]; then
    echo "FAIL: $label is '$got', expected '$want'"
    fail=1
  fi
}
chk "spec.name" scout '.spec.name // ""'
chk "spec.tier" small '.spec.tier // ""'
chk "spec.replicas" 2 '.spec.replicas // ""'
chk "status.phase" Accepted '.status.phase // ""'

if [ "$fail" -eq 0 ]; then
  echo "PASS: scout-request is accepted"
fi
exit "$fail"
