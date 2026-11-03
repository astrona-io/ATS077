#!/usr/bin/env bash
# Check: rollout-evidence matches the live numbers of outpost-scout.
set -uo pipefail

fail=0
if ! kubectl -n outpost get configmap rollout-evidence >/dev/null 2>&1; then
  echo "FAIL: ConfigMap rollout-evidence not found in outpost"
  exit 1
fi
if ! kubectl -n outpost get deployment outpost-scout >/dev/null 2>&1; then
  echo "FAIL: deployment outpost-scout not found in outpost"
  exit 1
fi

read_key() {
  kubectl -n outpost get configmap rollout-evidence -o json | jq -r --arg key "$1" '.data[$key] // ""'
}

compare() {
  local key="$1" live="$2" recorded
  recorded="$(read_key "$key")"
  if [ "$recorded" != "$live" ]; then
    echo "FAIL: key '$key' is '$recorded', the live value is '$live'"
    fail=1
  fi
}

compare generation "$(kubectl -n outpost get deployment outpost-scout -o jsonpath='{.metadata.generation}')"
compare observed-generation "$(kubectl -n outpost get deployment outpost-scout -o jsonpath='{.status.observedGeneration}')"
compare ready-replicas "$(kubectl -n outpost get deployment outpost-scout -o jsonpath='{.status.readyReplicas}')"

if [ "$fail" -eq 0 ]; then
  echo "PASS: rollout-evidence matches the live status of outpost-scout"
fi
exit "$fail"
