#!/usr/bin/env bash
# Check: the running pods (not the Deployment text) carry owner=bridge-team.
# Pods that are still terminating are ignored, so the rollout must be finished.
set -uo pipefail

fail=0
for name in scout probe shuttle; do
  pods="$(kubectl -n starfleet get pods -l "app=$name" -o json)"
  running="$(echo "$pods" | jq '[.items[] | select(.metadata.deletionTimestamp == null)] | length')"
  if [ "$running" -lt 1 ]; then
    echo "FAIL: no running pod found for $name"
    fail=1
    continue
  fi
  missing="$(echo "$pods" | jq -r '.items[] | select(.metadata.deletionTimestamp == null) | select(.metadata.labels.owner != "bridge-team") | .metadata.name')"
  if [ -n "$missing" ]; then
    echo "FAIL: pod $missing has no owner=bridge-team label; put the label in the pod template and wait for the rollout"
    fail=1
  fi
done
if [ "$fail" -eq 0 ]; then
  echo "PASS: all running pods of scout, probe and shuttle carry owner=bridge-team"
fi
exit "$fail"
