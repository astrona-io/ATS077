#!/usr/bin/env bash
# Starting state: the Starfleet workloads and a bare pod (no owner) that the
# learner must replace with a Deployment. Environment only.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl apply -f "$DIR/manifests/bare-pod.yaml"

for name in scout probe shuttle; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
kubectl -n outpost rollout status deployment/drifter --timeout=180s
kubectl -n starfleet wait --for=condition=Ready pod/shuttle-debug --timeout=180s
echo "[lab] Ready."
