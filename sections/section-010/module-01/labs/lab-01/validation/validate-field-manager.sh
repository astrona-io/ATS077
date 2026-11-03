#!/usr/bin/env bash
# Check: outpost-scout was applied server-side under the manager platform-team.
set -uo pipefail

if ! kubectl -n outpost get deployment outpost-scout >/dev/null 2>&1; then
  echo "FAIL: deployment outpost-scout not found in outpost"
  exit 1
fi

found="$(kubectl -n outpost get deployment outpost-scout --show-managed-fields -o json | jq -r '[.metadata.managedFields[] | select(.manager == "platform-team" and .operation == "Apply")] | length')"
if [ "$found" -lt 1 ]; then
  echo "FAIL: no managedFields entry with manager platform-team and operation Apply"
  exit 1
fi
echo "PASS: platform-team owns fields of outpost-scout through server-side apply"
