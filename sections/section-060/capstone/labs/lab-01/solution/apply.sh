#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

for sa in ci-build deploy-staging deploy-production; do
  kubectl -n ci create serviceaccount "$sa" --dry-run=client -o yaml | kubectl apply -f -
done

kubectl apply -f - <<'YAML'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pipeline-build
  namespace: ci
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get", "list", "create", "update", "patch"]
  - apiGroups: ["batch"]
    resources: ["jobs"]
    verbs: ["get", "list", "create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pipeline-build
  namespace: ci
subjects:
  - kind: ServiceAccount
    name: ci-build
    namespace: ci
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pipeline-build
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployer
  namespace: staging
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "patch", "update"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: deployer
  namespace: staging
subjects:
  - kind: ServiceAccount
    name: deploy-staging
    namespace: ci
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: deployer
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployer
  namespace: production
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "patch", "update"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: deployer
  namespace: production
subjects:
  - kind: ServiceAccount
    name: deploy-production
    namespace: ci
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: deployer
YAML

kubectl -n staging patch deployment scout --type=merge -p '{"spec":{"template":{"metadata":{"labels":{"release":"r2"}}}}}'
kubectl -n staging rollout status deployment/scout --timeout=180s
kubectl -n production patch deployment scout --type=merge -p '{"metadata":{"annotations":{"kubernetes.io/change-cause":"release r2"}},"spec":{"template":{"metadata":{"labels":{"release":"r2"}}}}}'
kubectl -n production rollout status deployment/scout --timeout=180s

IMAGE="$(kubectl -n production get deployment scout -o jsonpath='{.spec.template.spec.containers[0].image}')"
REV="$(kubectl -n production get deployment scout -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}')"
kubectl -n ci create configmap release-record \
  --from-literal=revision=r2 --from-literal=image="$IMAGE" \
  --from-literal=deployed-revision="$REV" --from-literal=previous-revision="$((REV - 1))" \
  --dry-run=client -o yaml | kubectl apply -f -
