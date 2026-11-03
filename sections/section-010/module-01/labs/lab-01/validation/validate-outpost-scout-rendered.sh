#!/usr/bin/env bash
# Check: the rendered result in outpost: name, replicas, label on object,
# selector and pod template, image.
set -uo pipefail

fail=0

if ! kubectl -n outpost get deployment outpost-scout >/dev/null 2>&1; then
  echo "FAIL: deployment outpost-scout not found in outpost"
  exit 1
fi

json="$(kubectl -n outpost get deployment outpost-scout -o json)"

replicas="$(echo "$json" | jq -r '.spec.replicas')"
if [ "$replicas" != "2" ]; then
  echo "FAIL: spec.replicas is $replicas, expected 2"
  fail=1
fi

ready="$(echo "$json" | jq -r '.status.availableReplicas // 0')"
if [ "$ready" -lt 2 ]; then
  echo "FAIL: only $ready replicas are available; wait for the rollout"
  fail=1
fi

for path in '.metadata.labels.tier' '.spec.selector.matchLabels.tier' '.spec.template.metadata.labels.tier'; do
  value="$(echo "$json" | jq -r "$path // \"\"")"
  if [ "$value" != "edge" ]; then
    echo "FAIL: $path is '$value', expected 'edge' (use includeSelectors: true)"
    fail=1
  fi
done

image="$(echo "$json" | jq -r '.spec.template.spec.containers[0].image')"
if [ "$image" != "ghcr.io/stefanprodan/podinfo:6.15.0" ]; then
  echo "FAIL: image is '$image', expected ghcr.io/stefanprodan/podinfo:6.15.0"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: outpost-scout is rendered with 2 replicas and the tier=edge label everywhere"
fi
exit "$fail"
