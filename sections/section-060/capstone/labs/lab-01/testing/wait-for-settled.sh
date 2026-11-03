#!/usr/bin/env bash
# Runs under `astrona test` after the reference solution.
set -euo pipefail

for env in staging production; do
  kubectl -n "$env" rollout status deployment/scout --timeout=180s
  for _ in $(seq 1 60); do
    terminating="$(kubectl -n "$env" get pods -o json | jq '[.items[] | select(.metadata.deletionTimestamp != null)] | length')"
    [ "$terminating" = "0" ] && break
    sleep 2
  done
done
echo "[testing] settled."
