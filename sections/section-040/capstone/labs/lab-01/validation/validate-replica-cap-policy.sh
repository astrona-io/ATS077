#!/usr/bin/env bash
# Check: the policy, its binding, the namespace label and the real behavior.
set -uo pipefail

fail=0
fp="$(kubectl get validatingadmissionpolicy starfleet-replica-cap -o jsonpath='{.spec.failurePolicy}' 2>/dev/null || true)"
[ "$fp" = "Fail" ] || { echo "FAIL: policy starfleet-replica-cap has failurePolicy '$fp', expected 'Fail'"; fail=1; }

act="$(kubectl get validatingadmissionpolicybinding starfleet-replica-cap-binding -o jsonpath='{.spec.validationActions[*]}' 2>/dev/null || true)"
[ "$act" = "Deny" ] || { echo "FAIL: binding starfleet-replica-cap-binding has actions '$act', expected 'Deny'"; fail=1; }

lbl="$(kubectl get namespace starfleet -o jsonpath='{.metadata.labels.platform}' 2>/dev/null || true)"
[ "$lbl" = "managed" ] || { echo "FAIL: namespace starfleet has platform='$lbl', expected 'managed'"; fail=1; }

if [ "$fail" -ne 0 ]; then
  exit 1
fi

dry() { kubectl -n "$1" create deployment grader-probe --image=curlimages/curl:8.22.0 --replicas="$2" --dry-run=server >/dev/null 2>&1; }

# The policy needs a few seconds to become active.
enforced=0
for i in $(seq 1 30); do
  if ! dry starfleet 4; then enforced=1; break; fi
  sleep 2
done
[ "$enforced" -eq 1 ] || { echo "FAIL: 4 replicas are still accepted in starfleet"; fail=1; }
dry starfleet 2 || { echo "FAIL: 2 replicas are rejected in starfleet"; fail=1; }
dry outpost 4 || { echo "FAIL: 4 replicas are rejected in outpost, which is not managed"; fail=1; }

if [ "$fail" -eq 0 ]; then
  echo "PASS: the replica cap is enforced where the binding selects"
fi
exit "$fail"
