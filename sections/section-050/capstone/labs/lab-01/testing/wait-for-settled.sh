#!/usr/bin/env bash
# Runs under `astrona test` after the reference solution.
set -euo pipefail

kubectl -n adopt rollout status deployment/engine-web --timeout=180s
for _ in $(seq 1 60); do
  terminating="$(kubectl -n adopt get pods -o json | jq '[.items[] | select(.metadata.deletionTimestamp != null)] | length')"
  [ "$terminating" = "0" ] && break
  sleep 2
done
echo "[testing] settled."
