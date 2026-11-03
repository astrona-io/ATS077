#!/usr/bin/env bash
# Check: probe is back on its original image, has a readiness probe and all
# replicas are updated and available.
set -uo pipefail

fail=0
json="$(kubectl -n starfleet get deployment probe -o json 2>/dev/null || true)"
if [ -z "$json" ]; then
  echo "FAIL: deployment probe not found in starfleet"
  exit 1
fi
image="$(echo "$json" | jq -r '.spec.template.spec.containers[0].image')"
if [ "$image" != "mccutchen/go-httpbin:2.25.0" ]; then
  echo "FAIL: probe image is '$image', expected mccutchen/go-httpbin:2.25.0"
  fail=1
fi
path="$(echo "$json" | jq -r '.spec.template.spec.containers[0].readinessProbe.httpGet.path // ""')"
if [ -z "$path" ]; then
  echo "FAIL: the probe container has no readiness probe with an httpGet handler"
  fail=1
fi
want="$(echo "$json" | jq -r '.spec.replicas')"
updated="$(echo "$json" | jq -r '.status.updatedReplicas // 0')"
available="$(echo "$json" | jq -r '.status.availableReplicas // 0')"
total="$(echo "$json" | jq -r '.status.replicas // 0')"
if [ "$updated" != "$want" ] || [ "$available" != "$want" ] || [ "$total" != "$want" ]; then
  echo "FAIL: replicas want=$want updated=$updated available=$available total=$total; wait for the rollout"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: probe is recovered and has a readiness probe"
fi
exit "$fail"
