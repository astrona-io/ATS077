#!/usr/bin/env bash
# Runs under `astrona test` after the reference solution.
set -euo pipefail
kubectl -n production rollout status deployment/scout --timeout=240s
for i in $(seq 1 60); do
  s="$(kubectl -n argocd get application scout-production -o jsonpath='{.status.sync.status}/{.status.health.status}' 2>/dev/null || true)"
  [ "$s" = "Synced/Healthy" ] && break
  sleep 3
done
echo "[testing] settled."
