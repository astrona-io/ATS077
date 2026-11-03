#!/usr/bin/env bash
# Runs under `astrona test` after the reference solution.
set -euo pipefail

for ns in bridge engine; do
  kubectl -n "$ns" rollout status deployment/web --timeout=180s
done
echo "[testing] settled."
