#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

# 1. Roll back probe, then add the readiness probe.
kubectl -n starfleet rollout undo deployment/probe
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet patch deployment probe --type=strategic -p '{
  "spec":{"template":{"spec":{"containers":[{"name":"probe","readinessProbe":{"httpGet":{"path":"/status/200","port":"http"},"periodSeconds":5}}]}}}}'
kubectl -n starfleet rollout status deployment/probe --timeout=180s

# 2. Restricted outpost and a compliant drifter.
kubectl label namespace outpost pod-security.kubernetes.io/enforce=restricted
kubectl -n outpost patch deployment drifter --type=strategic -p '{
  "spec":{"template":{
    "metadata":{"labels":{"owner":"drifter-team"}},
    "spec":{
      "securityContext":{"runAsNonRoot":true,"runAsUser":1000,"seccompProfile":{"type":"RuntimeDefault"}},
      "containers":[{"name":"drifter","securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}}]}}}}'
kubectl -n outpost rollout status deployment/drifter --timeout=180s

# 3. Team access.
kubectl apply -f - <<'YAML'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployer
  namespace: outpost
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
  - apiGroups: [""]
    resources: ["pods", "pods/log"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: drifter-team-deployer
  namespace: outpost
subjects:
  - kind: Group
    name: drifter-team
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: deployer
  apiGroup: rbac.authorization.k8s.io
YAML
echo "[solution] Applied."
