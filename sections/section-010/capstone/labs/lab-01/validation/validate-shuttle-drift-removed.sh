#!/usr/bin/env bash
# Check: shuttle has the declared replica count and platform-team owns the field.
set -uo pipefail

fail=0
json="$(kubectl -n starfleet get deployment shuttle --show-managed-fields -o json 2>/dev/null || true)"
if [ -z "$json" ]; then
  echo "FAIL: deployment shuttle not found in starfleet"
  exit 1
fi

replicas="$(echo "$json" | jq -r '.spec.replicas')"
if [ "$replicas" != "1" ]; then
  echo "FAIL: shuttle has spec.replicas $replicas, the declaration says 1"
  fail=1
fi

owner="$(echo "$json" | jq -r '[.metadata.managedFields[] | select(.manager == "platform-team" and .operation == "Apply") | select(.fieldsV1."f:spec"."f:replicas" != null)] | length')"
if [ "$owner" -lt 1 ]; then
  echo "FAIL: the manager platform-team (Apply) does not own spec.replicas"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: shuttle matches its declaration and platform-team owns spec.replicas"
fi
exit "$fail"
