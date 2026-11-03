#!/usr/bin/env bash
# Runs under `astrona test` after the reference solution: waits for the rollouts
# and for the old pods to be gone.
set -euo pipefail

for name in scout probe shuttle; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
kubectl -n sandbox rollout status deployment/crew --timeout=180s
for i in $(seq 1 30); do
  terminating="$(kubectl get pods -A -o json | jq '[.items[] | select(.metadata.deletionTimestamp != null)] | length')"
  if [ "$terminating" = "0" ]; then
    echo "[testing] settled."
    exit 0
  fi
  sleep 2
done
echo "[testing] pods did not finish terminating in time." >&2
exit 1
