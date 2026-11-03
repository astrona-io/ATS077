#!/usr/bin/env bash
# Check: drifter-web is a documented exception.
set -uo pipefail

dep="$(kubectl -n adopt get deployment drifter-web -o json 2>/dev/null || true)"
if [ -z "$dep" ]; then
  echo "FAIL: deployment drifter-web does not exist in adopt"
  exit 1
fi

fail=0
chk() {
  local label="$1" filter="$2" got
  got="$(jq -r "$filter" <<<"$dep")"
  if [ -z "$got" ]; then
    echo "FAIL: $label is missing or empty"
    fail=1
  fi
}

path="$(jq -r '.metadata.labels["platform.starfleet.io/path"] // ""' <<<"$dep")"
if [ "$path" != "exception" ]; then
  echo "FAIL: label platform.starfleet.io/path on drifter-web is '$path', expected 'exception'"
  fail=1
fi
chk "annotation platform.starfleet.io/exception-reason" '.metadata.annotations["platform.starfleet.io/exception-reason"] // ""'
chk "annotation platform.starfleet.io/exception-review" '.metadata.annotations["platform.starfleet.io/exception-review"] // ""'

if [ "$fail" -eq 0 ]; then
  echo "PASS: drifter-web is recorded as an exception with a reason and a review date"
fi
exit "$fail"
