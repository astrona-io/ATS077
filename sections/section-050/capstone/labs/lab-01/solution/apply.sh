#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: engine-web
  namespace: adopt
  labels:
    app: engine-web
    platform.starfleet.io/path: golden
spec:
  replicas: 1
  selector:
    matchLabels:
      app: engine-web
  template:
    metadata:
      labels:
        app: engine-web
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
kubectl -n adopt rollout status deployment/engine-web --timeout=180s

kubectl -n adopt label deployment drifter-web platform.starfleet.io/path=exception --overwrite
kubectl -n adopt annotate deployment drifter-web \
  platform.starfleet.io/exception-reason="legacy image, no probe endpoint agreed" \
  platform.starfleet.io/exception-review="2027-01-31" --overwrite

kubectl -n adopt create configmap adoption-report \
  --from-literal=onpath=2 --from-literal=exceptions=1 --from-literal=total=3 \
  --dry-run=client -o yaml | kubectl apply -f -
