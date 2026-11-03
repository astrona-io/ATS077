#!/usr/bin/env bash
# Check: drifter-debug is declared by a Deployment and no bare pod remains.
set -uo pipefail

fail=0
ready="$(kubectl -n outpost get deployment drifter-debug -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ -z "$ready" ] || [ "$ready" -lt 1 ]; then
  echo "FAIL: deployment drifter-debug in outpost has no available replica"
  exit 1
fi
if kubectl -n outpost get pod drifter-debug >/dev/null 2>&1; then
  echo "FAIL: the bare pod drifter-debug still exists"
  fail=1
fi
unowned="$(kubectl -n outpost get pods -l app=drifter-debug -o json | jq -r '.items[] | select(.metadata.deletionTimestamp == null) | select((.metadata.ownerReferences // []) | map(select(.kind == "ReplicaSet")) | length == 0) | .metadata.name')"
if [ -n "$unowned" ]; then
  echo "FAIL: pod(s) without a ReplicaSet owner: $unowned"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: drifter-debug is owned by a Deployment"
fi
exit "$fail"
