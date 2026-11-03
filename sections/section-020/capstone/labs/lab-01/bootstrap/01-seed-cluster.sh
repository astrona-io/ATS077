#!/usr/bin/env bash
# Starting state: the workloads, then a rollout of probe to an image tag that
# does not exist. The old pod keeps running. Environment only.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
for name in scout probe shuttle; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
kubectl -n outpost rollout status deployment/drifter --timeout=180s

# The failed rollout. Do not wait for it: it never finishes.
kubectl -n starfleet patch deployment probe --type=merge -p '{"spec":{"progressDeadlineSeconds":60}}'
kubectl -n starfleet set image deployment/probe probe=mccutchen/go-httpbin:0.0.0-missing
echo "[lab] Ready."
