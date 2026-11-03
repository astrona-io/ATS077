#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

kubectl -n starfleet delete pod shuttle-debug
cat > "$WORK/shuttle-debug.yaml" <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shuttle-debug
  namespace: starfleet
  labels:
    app: shuttle-debug
spec:
  replicas: 2
  selector:
    matchLabels:
      app: shuttle-debug
  template:
    metadata:
      labels:
        app: shuttle-debug
    spec:
      serviceAccountName: shuttle
      containers:
        - name: shuttle-debug
          image: curlimages/curl:8.22.0
          command: ["sh", "-c", "while true; do sleep 30; done"]
YAML
kubectl apply -f "$WORK/shuttle-debug.yaml"

mkdir -p "$WORK/base" "$WORK/overlays/outpost"
cat > "$WORK/base/deployment.yaml" <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
  labels:
    app: scout
spec:
  replicas: 1
  selector:
    matchLabels:
      app: scout
  template:
    metadata:
      labels:
        app: scout
    spec:
      containers:
        - name: scout
          image: ghcr.io/stefanprodan/podinfo:6.15.0
          ports:
            - name: http
              containerPort: 9898
YAML
cat > "$WORK/base/kustomization.yaml" <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
YAML
cat > "$WORK/overlays/outpost/kustomization.yaml" <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: outpost
namePrefix: outpost-
resources:
  - ../../base
labels:
  - pairs:
      tier: edge
    includeSelectors: true
patches:
  - target:
      kind: Deployment
      name: scout
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 2
YAML
kubectl kustomize "$WORK/overlays/outpost" | kubectl apply --server-side --field-manager=platform-team -f -
echo "[solution] Applied."
