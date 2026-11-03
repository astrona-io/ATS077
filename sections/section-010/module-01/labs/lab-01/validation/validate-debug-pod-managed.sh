#!/usr/bin/env bash
# Check: shuttle-debug is declared by a Deployment with 2 available replicas,
# and every pod with that label has a ReplicaSet owner (no bare pod remains).
set -uo pipefail

fail=0

ready="$(kubectl -n starfleet get deployment shuttle-debug -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ -z "$ready" ] || [ "$ready" -lt 2 ]; then
  echo "FAIL: deployment shuttle-debug in starfleet needs 2 available replicas (has '${ready:-none}')"
  exit 1
fi

if kubectl -n starfleet get pod shuttle-debug >/dev/null 2>&1; then
  echo "FAIL: the bare pod shuttle-debug still exists"
  fail=1
fi

unowned="$(kubectl -n starfleet get pods -l app=shuttle-debug -o json | jq -r '.items[] | select(.metadata.deletionTimestamp == null) | select((.metadata.ownerReferences // []) | map(select(.kind == "ReplicaSet")) | length == 0) | .metadata.name')"
if [ -n "$unowned" ]; then
  echo "FAIL: pod(s) without a ReplicaSet owner: $unowned"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: shuttle-debug is owned by a Deployment with 2 available replicas"
fi
exit "$fail"
