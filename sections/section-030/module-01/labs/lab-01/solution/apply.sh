#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

kubectl apply -f - <<'YAML'
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: dev
spec:
  hard:
    pods: "4"
    requests.memory: 256Mi
    limits.memory: 512Mi
---
apiVersion: v1
kind: LimitRange
metadata:
  name: dev-defaults
  namespace: dev
spec:
  limits:
    - type: Container
      defaultRequest:
        memory: 16Mi
      default:
        memory: 64Mi
YAML
kubectl -n dev create deployment crew --image=ghcr.io/stefanprodan/podinfo:6.15.0 --replicas=2
kubectl -n dev rollout status deployment/crew --timeout=180s

kubectl -n test patch configmap app-config --type=merge -p '{"data":{"DATABASE_HOST":"db.test.starfleet.internal"}}'
kubectl -n prod patch configmap app-config --type=merge -p '{"data":{"LOG_LEVEL":"warn"}}'
echo "[solution] Applied."
