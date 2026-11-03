#!/usr/bin/env bash
# Check: the rendered Deployments in outpost.
set -uo pipefail

fail=0

check_deployment() {
  local name="$1" want_replicas="$2" json
  if ! json="$(kubectl -n outpost get deployment "$name" -o json 2>/dev/null)"; then
    echo "FAIL: deployment $name not found in outpost"
    fail=1
    return
  fi
  local replicas
  replicas="$(echo "$json" | jq -r '.spec.replicas')"
  if [ "$replicas" != "$want_replicas" ]; then
    echo "FAIL: $name has $replicas replicas, expected $want_replicas"
    fail=1
  fi
  for path in '.metadata.labels.team' '.spec.selector.matchLabels.team' '.spec.template.metadata.labels.team'; do
    if [ "$(echo "$json" | jq -r "$path // \"\"")" != "drifter" ]; then
      echo "FAIL: $name has no team=drifter at $path"
      fail=1
    fi
  done
  local cpu memory
  cpu="$(echo "$json" | jq -r '.spec.template.spec.containers[0].resources.requests.cpu // ""')"
  memory="$(echo "$json" | jq -r '.spec.template.spec.containers[0].resources.requests.memory // ""')"
  if [ -z "$cpu" ] || [ -z "$memory" ]; then
    echo "FAIL: $name needs CPU and memory requests"
    fail=1
  fi
  local available
  available="$(echo "$json" | jq -r '.status.availableReplicas // 0')"
  if [ "$available" -lt "$want_replicas" ]; then
    echo "FAIL: $name has $available available replicas, expected $want_replicas"
    fail=1
  fi
}

check_deployment outpost-scout 2
check_deployment outpost-probe 1

if [ "$fail" -eq 0 ]; then
  echo "PASS: outpost-scout and outpost-probe are rendered as required"
fi
exit "$fail"
