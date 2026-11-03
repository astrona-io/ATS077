#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# 1. Remove the drift from shuttle.
kubectl -n starfleet get configmap desired-state -o jsonpath='{.data.shuttle\.yaml}' > "$WORK/shuttle.yaml"
kubectl apply --server-side --force-conflicts --field-manager=platform-team -f "$WORK/shuttle.yaml"

# 2. Render both Deployments for outpost.
mkdir -p "$WORK/base" "$WORK/overlays/outpost"
cat > "$WORK/base/scout.yaml" <<'YAML'
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
cat > "$WORK/base/probe.yaml" <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe
  labels:
    app: probe
spec:
  replicas: 1
  selector:
    matchLabels:
      app: probe
  template:
    metadata:
      labels:
        app: probe
    spec:
      containers:
        - name: probe
          image: mccutchen/go-httpbin:2.25.0
          ports:
            - name: http
              containerPort: 8080
YAML
cat > "$WORK/base/kustomization.yaml" <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - scout.yaml
  - probe.yaml
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
      team: drifter
    includeSelectors: true
patches:
  - target:
      kind: Deployment
      name: scout
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 2
  - target:
      kind: Deployment
    patch: |-
      - op: add
        path: /spec/template/spec/containers/0/resources
        value:
          requests:
            cpu: 10m
            memory: 32Mi
YAML
kubectl kustomize "$WORK/overlays/outpost" | kubectl apply -f -

# 3. Replace the bare pod.
kubectl -n outpost delete pod drifter-debug
kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: drifter-debug
  namespace: outpost
  labels:
    app: drifter-debug
spec:
  replicas: 1
  selector:
    matchLabels:
      app: drifter-debug
  template:
    metadata:
      labels:
        app: drifter-debug
    spec:
      serviceAccountName: drifter
      containers:
        - name: drifter-debug
          image: curlimages/curl:8.22.0
          command: ["sh", "-c", "while true; do sleep 30; done"]
YAML

kubectl -n outpost rollout status deployment/outpost-scout --timeout=180s
kubectl -n outpost rollout status deployment/outpost-probe --timeout=180s
kubectl -n outpost rollout status deployment/drifter-debug --timeout=180s

# 4. Record the evidence.
generation="$(kubectl -n outpost get deployment outpost-scout -o jsonpath='{.metadata.generation}')"
observed="$(kubectl -n outpost get deployment outpost-scout -o jsonpath='{.status.observedGeneration}')"
ready="$(kubectl -n outpost get deployment outpost-scout -o jsonpath='{.status.readyReplicas}')"
kubectl -n outpost create configmap rollout-evidence \
  --from-literal=generation="$generation" \
  --from-literal=observed-generation="$observed" \
  --from-literal=ready-replicas="$ready"
echo "[solution] Applied."
