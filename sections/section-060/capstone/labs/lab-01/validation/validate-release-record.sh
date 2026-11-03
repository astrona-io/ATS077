#!/usr/bin/env bash
# Check: the release record matches the cluster.
set -uo pipefail

prod="$(kubectl -n production get deployment scout -o json 2>/dev/null || true)"
if [ -z "$prod" ]; then
  echo "FAIL: deployment scout does not exist in production"
  exit 1
fi
image="$(jq -r '.spec.template.spec.containers[0].image' <<<"$prod")"
rev="$(jq -r '.metadata.annotations["deployment.kubernetes.io/revision"] // ""' <<<"$prod")"
if ! [[ "$rev" =~ ^[0-9]+$ ]]; then
  echo "FAIL: production has no numeric revision annotation"
  exit 1
fi
prev=$((rev - 1))

cm="$(kubectl -n ci get configmap release-record -o json 2>/dev/null || true)"
if [ -z "$cm" ]; then
  echo "FAIL: ConfigMap release-record does not exist in ci"
  exit 1
fi

fail=0
chk() {
  local key="$1" want="$2" got
  got="$(jq -r ".data[\"$key\"] // \"\"" <<<"$cm")"
  if [ "$got" != "$want" ]; then
    echo "FAIL: release-record $key is '$got', expected '$want'"
    fail=1
  fi
}
chk revision r2
chk image "$image"
chk deployed-revision "$rev"
chk previous-revision "$prev"

if [ "$fail" -eq 0 ]; then
  echo "PASS: release-record matches production (revision $rev, previous $prev)"
fi
exit "$fail"
