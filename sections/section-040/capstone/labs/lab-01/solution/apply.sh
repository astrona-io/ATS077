#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

kubectl label namespace starfleet platform=managed
kubectl apply -f - <<'YAML'
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: starfleet-replica-cap
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
      - apiGroups: ["apps"]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["deployments"]
  validations:
    - expression: "object.spec.replicas <= 3"
      message: "a Deployment may have at most 3 replicas"
---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: starfleet-replica-cap-binding
spec:
  policyName: starfleet-replica-cap
  validationActions: ["Deny"]
  matchResources:
    namespaceSelector:
      matchLabels:
        platform: managed
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: apprequest-submitter
rules:
  - apiGroups: ["platform.starfleet.io"]
    resources: ["apprequests"]
    verbs: ["create", "get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: drifter-team-submit
  namespace: outpost
subjects:
  - kind: Group
    name: drifter-team
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: apprequest-submitter
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: apprequest-controller
rules:
  - apiGroups: ["platform.starfleet.io"]
    resources: ["apprequests"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["platform.starfleet.io"]
    resources: ["apprequests/status"]
    verbs: ["update", "patch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: apprequest-controller
subjects:
  - kind: ServiceAccount
    name: apprequest-controller
    namespace: starfleet
roleRef:
  kind: ClusterRole
  name: apprequest-controller
  apiGroup: rbac.authorization.k8s.io
YAML
echo "[solution] Applied."
