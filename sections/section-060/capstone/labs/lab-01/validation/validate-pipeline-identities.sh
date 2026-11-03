#!/usr/bin/env bash
# Check: three separate pipeline identities with narrow rights, tested with can-i.
set -uo pipefail

fail=0
for sa in ci-build deploy-staging deploy-production; do
  if ! kubectl -n ci get serviceaccount "$sa" >/dev/null 2>&1; then
    echo "FAIL: ServiceAccount $sa does not exist in ci"
    fail=1
  fi
done

# expect SA yes|no verb resource namespace
expect() {
  local sa="$1" want="$2" verb="$3" res="$4" ns="$5" got
  got="$(kubectl auth can-i "$verb" "$res" -n "$ns" --as="system:serviceaccount:ci:$sa" 2>/dev/null || true)"
  if [ "$got" != "$want" ]; then
    echo "FAIL: $sa can-i $verb $res in $ns is '$got', expected '$want'"
    fail=1
  fi
}

expect ci-build yes create configmaps ci
expect ci-build yes patch configmaps ci
expect ci-build yes create jobs.batch ci
expect ci-build no patch deployments.apps staging
expect ci-build no patch deployments.apps production
expect ci-build no get secrets ci
expect ci-build no create configmaps production

expect deploy-staging yes get deployments.apps staging
expect deploy-staging yes patch deployments.apps staging
expect deploy-staging no patch deployments.apps production
expect deploy-staging no delete deployments.apps staging
expect deploy-staging no get secrets staging
expect deploy-staging no create configmaps ci

expect deploy-production yes get deployments.apps production
expect deploy-production yes patch deployments.apps production
expect deploy-production no patch deployments.apps staging
expect deploy-production no delete deployments.apps production
expect deploy-production no get secrets production

for sa in ci-build deploy-staging deploy-production; do
  expect "$sa" no patch deployments.apps starfleet
  expect "$sa" no get secrets kube-system
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: the three pipeline identities have separate, narrow rights"
fi
exit "$fail"
