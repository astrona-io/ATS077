#!/usr/bin/env bash
# Runs under `astrona test` after the reference solution.
set -euo pipefail

# The policy needs a short time before the API server enforces it.
for i in $(seq 1 30); do
  if ! kubectl -n starfleet create deployment settle-probe --image=curlimages/curl:8.22.0 --replicas=4 --dry-run=server >/dev/null 2>&1; then
    echo "[testing] settled."
    exit 0
  fi
  sleep 2
done
echo "[testing] the policy is not enforced yet." >&2
exit 1
