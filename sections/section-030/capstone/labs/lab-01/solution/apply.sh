#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

# 1. Guardrails.
for ns in dev test prod; do
  kubectl label namespace "$ns" "environment=$ns" --overwrite
done
kubectl label namespace prod pod-security.kubernetes.io/enforce=restricted --overwrite
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: ResourceQuota
metadata:
  name: test-quota
  namespace: test
spec:
  hard:
    pods: "5"
YAML

# 2. Access: read only in prod.
kubectl -n prod delete rolebinding drifter-team-edit
kubectl -n prod create rolebinding drifter-team-view --clusterrole=view --group=drifter-team

# 3. Data separation in test.
kubectl -n test patch configmap app-config --type=merge -p '{"data":{"DATABASE_HOST":"db.test.starfleet.internal"}}'
kubectl -n test create secret generic db-credentials --from-literal=password=test-only-value --dry-run=client -o yaml | kubectl replace -f -
echo "[solution] Applied."
