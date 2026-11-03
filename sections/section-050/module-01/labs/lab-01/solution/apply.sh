#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

W="$(mktemp -d)"
mkdir -p "$W/base" "$W/overlays/bridge" "$W/overlays/engine"

cat > "$W/base/deployment.yaml" <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  labels:
    app: web
    platform.starfleet.io/path: golden
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
        platform.starfleet.io/path: golden
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: web
          image: ghcr.io/stefanprodan/podinfo:6.15.0
          ports:
            - name: http
              containerPort: 9898
          readinessProbe:
            httpGet:
              path: /readyz
              port: http
          resources:
            requests:
              cpu: 10m
              memory: 32Mi
            limits:
              memory: 64Mi
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop: ["ALL"]
YAML

cat > "$W/base/service.yaml" <<'YAML'
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  selector:
    app: web
  ports:
    - name: http
      port: 80
      targetPort: http
YAML

cat > "$W/base/kustomization.yaml" <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
YAML

cat > "$W/overlays/bridge/kustomization.yaml" <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: bridge
resources:
  - ../../base
replicas:
  - name: web
    count: 2
labels:
  - pairs:
      team: bridge
    includeTemplates: true
YAML

cat > "$W/overlays/engine/kustomization.yaml" <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: engine
resources:
  - ../../base
labels:
  - pairs:
      team: engine
    includeTemplates: true
YAML

kubectl apply -k "$W/overlays/bridge"
kubectl apply -k "$W/overlays/engine"
