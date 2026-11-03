#!/usr/bin/env bash
# Runs under `astrona test` after the reference solution: waits for both
# Deployments to be available.
set -euo pipefail

kubectl -n starfleet rollout status deployment/shuttle-debug --timeout=180s
kubectl -n outpost rollout status deployment/outpost-scout --timeout=180s
echo "[testing] settled."
