#!/usr/bin/env bash
# Check: crew runs in dev with defaults supplied by the LimitRange.
set -uo pipefail

fail=0
dep="$(kubectl -n dev get deployment crew -o json 2>/dev/null || true)"
if [ -z "$dep" ]; then
  echo "FAIL: deployment crew does not exist in dev"
  exit 1
fi

avail="$(jq -r '.status.availableReplicas // 0' <<<"$dep")"
[ "$avail" -ge 2 ] || { echo "FAIL: crew has $avail available replicas, expected 2"; fail=1; }

image="$(jq -r '.spec.template.spec.containers[0].image' <<<"$dep")"
[ "$image" = "ghcr.io/stefanprodan/podinfo:6.15.0" ] || { echo "FAIL: crew runs image '$image'"; fail=1; }

res="$(jq -r '(.spec.template.spec.containers[0].resources // {}) | length' <<<"$dep")"
[ "$res" = "0" ] || { echo "FAIL: crew declares resources itself; the LimitRange should supply them"; fail=1; }

bad="$(kubectl -n dev get pods -o json | jq '[.items[] | select(.metadata.name | startswith("crew-")) | select(.metadata.deletionTimestamp == null) | select(.spec.containers[0].resources.limits.memory != "64Mi")] | length')"
[ "$bad" = "0" ] || { echo "FAIL: $bad crew pod(s) do not have the default memory limit 64Mi"; fail=1; }

if [ "$fail" -eq 0 ]; then
  echo "PASS: crew runs two replicas with the defaults from the LimitRange"
fi
exit "$fail"
