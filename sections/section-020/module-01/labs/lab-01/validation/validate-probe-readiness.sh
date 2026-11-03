#!/usr/bin/env bash
# Check: probe has an HTTP readiness probe and an available replica.
set -uo pipefail

json="$(kubectl -n starfleet get deployment probe -o json 2>/dev/null || true)"
if [ -z "$json" ]; then
  echo "FAIL: deployment probe not found in starfleet"
  exit 1
fi
path="$(echo "$json" | jq -r '.spec.template.spec.containers[] | select(.name == "probe") | .readinessProbe.httpGet.path // ""')"
if [ -z "$path" ]; then
  echo "FAIL: the probe container has no readinessProbe with an httpGet handler"
  exit 1
fi
available="$(echo "$json" | jq -r '.status.availableReplicas // 0')"
if [ "$available" -lt 1 ]; then
  echo "FAIL: probe has no available replica; the readiness probe path '$path' may be wrong"
  exit 1
fi
echo "PASS: probe has a readiness probe on $path and is available"
