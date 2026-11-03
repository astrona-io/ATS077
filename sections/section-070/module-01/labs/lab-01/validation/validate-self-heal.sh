#!/usr/bin/env bash
# Check: a manual change to the live Deployment is reverted by the controller.
set -uo pipefail

want="$(kubectl -n staging get deployment scout -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
if [ "$want" != "1" ]; then
  echo "FAIL: scout in staging has $want replicas before the test, expected 1 (the value in the overlay)"
  exit 1
fi
if ! kubectl -n staging scale deployment scout --replicas=3 >/dev/null 2>&1; then
  echo "FAIL: could not scale scout in staging for the test"
  exit 1
fi
for i in $(seq 1 45); do
  got="$(kubectl -n staging get deployment scout -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
  if [ "$got" = "1" ]; then
    echo "PASS: the manual change to 3 replicas was reverted to 1"
    exit 0
  fi
  sleep 2
done
kubectl -n staging scale deployment scout --replicas=1 >/dev/null 2>&1 || true
echo "FAIL: scout stayed at $got replicas, so the controller did not revert the manual change (is selfHeal enabled?)"
exit 1
