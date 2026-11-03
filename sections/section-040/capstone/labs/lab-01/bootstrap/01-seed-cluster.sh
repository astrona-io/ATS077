#!/usr/bin/env bash
# Starting state: the workloads, the AppRequest CRD and the controller's service account. Environment only.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl apply -f "$DIR/manifests/crd.yaml"
kubectl wait --for=condition=Established crd/apprequests.platform.starfleet.io --timeout=60s
for name in scout probe shuttle; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
kubectl -n outpost rollout status deployment/drifter --timeout=180s
echo "[lab] Ready."
