#!/usr/bin/env bash
# Check: environment labels, Pod Security in prod only, and a quota in test.
set -uo pipefail

fail=0
for ns in dev test prod; do
  got="$(kubectl get namespace "$ns" -o jsonpath='{.metadata.labels.environment}' 2>/dev/null || true)"
  [ "$got" = "$ns" ] || { echo "FAIL: namespace $ns has environment='$got', expected '$ns'"; fail=1; }
done

psa() { kubectl get namespace "$1" -o json | jq -r '.metadata.labels["pod-security.kubernetes.io/enforce"] // ""'; }
[ "$(psa prod)" = "restricted" ] || { echo "FAIL: prod does not enforce restricted"; fail=1; }
for ns in dev test; do
  v="$(psa "$ns")"
  [ -z "$v" ] || { echo "FAIL: $ns enforces '$v'; only prod should enforce restricted"; fail=1; }
done

pods="$(kubectl -n test get resourcequota test-quota -o jsonpath='{.spec.hard.pods}' 2>/dev/null || true)"
[ "$pods" = "5" ] || { echo "FAIL: ResourceQuota test-quota in test has pods='$pods', expected '5'"; fail=1; }

if [ "$fail" -eq 0 ]; then
  echo "PASS: the environments carry their labels, prod is restricted and test has its quota"
fi
exit "$fail"
