#!/usr/bin/env bash
# Check: the build record ties revision, artifact and checks together.
set -uo pipefail

rev="$(kubectl -n ci get configmap source -o jsonpath='{.data.revision}' 2>/dev/null || true)"
cm="$(kubectl -n ci get configmap build-record -o json 2>/dev/null || true)"
if [ -z "$cm" ]; then
  echo "FAIL: ConfigMap build-record does not exist in ci"
  exit 1
fi

fail=0
chk() {
  local key="$1" want="$2" got
  got="$(jq -r ".data[\"$key\"] // \"\"" <<<"$cm")"
  if [ "$got" != "$want" ]; then
    echo "FAIL: build-record $key is '$got', expected '$want'"
    fail=1
  fi
}
chk revision "$rev"
chk image ghcr.io/stefanprodan/podinfo:6.15.0
chk checks passed
chk job unit-checks

if [ "$fail" -eq 0 ]; then
  echo "PASS: build-record names revision $rev, the pinned image and the passing checks"
fi
exit "$fail"
