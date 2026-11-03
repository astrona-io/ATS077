#!/usr/bin/env bash
# Starting state: workloads, the declaration of shuttle in a ConfigMap, a
# shuttle scaled to 4 by hand (drift) and a bare pod in outpost.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl apply -f "$DIR/manifests/drift.yaml"

for name in scout probe shuttle; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
kubectl -n outpost rollout status deployment/drifter --timeout=180s

# The drift: a person scaled shuttle by hand.
kubectl -n starfleet scale deployment shuttle --replicas=4
kubectl -n starfleet rollout status deployment/shuttle --timeout=180s
kubectl -n outpost wait --for=condition=Ready pod/drifter-debug --timeout=180s
echo "[lab] Ready."
