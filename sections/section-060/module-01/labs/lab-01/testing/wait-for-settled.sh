#!/usr/bin/env bash
# Runs under `astrona test` after the reference solution.
set -euo pipefail

for ns in staging production; do
  kubectl -n "$ns" rollout status deployment/scout --timeout=180s
done
kubectl -n ci wait --for=condition=complete job/unit-checks --timeout=120s
echo "[testing] settled."
