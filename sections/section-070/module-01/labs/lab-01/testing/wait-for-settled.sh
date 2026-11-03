#!/usr/bin/env bash
# Runs under `astrona test` after the reference solution.
set -euo pipefail
kubectl -n staging rollout status deployment/scout --timeout=180s
for i in $(seq 1 60); do
  s="$(kubectl -n argocd get application scout-staging -o jsonpath='{.status.sync.status}/{.status.health.status}' 2>/dev/null || true)"
  [ "$s" = "Synced/Healthy" ] && break
  sleep 3
done
echo "[testing] settled."
