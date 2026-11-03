#!/usr/bin/env bash
# Runs under `astrona test` after the reference solution.
set -euo pipefail

kubectl wait --for=condition=Established crd/apprequests.platform.starfleet.io --timeout=60s
echo "[testing] settled."
