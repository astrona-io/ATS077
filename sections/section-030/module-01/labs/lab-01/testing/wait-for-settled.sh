#!/usr/bin/env bash
# Runs under `astrona test` after the reference solution.
set -euo pipefail

kubectl -n dev rollout status deployment/crew --timeout=180s
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
