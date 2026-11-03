#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

REVISION="$(kubectl -n ci get configmap source -o jsonpath='{.data.revision}')"
IMAGE=ghcr.io/stefanprodan/podinfo:6.15.0

kubectl apply -f - <<YAML
apiVersion: batch/v1
kind: Job
metadata:
  name: unit-checks
  namespace: ci
  labels:
    ci.starfleet.io/revision: $REVISION
spec:
  backoffLimit: 0
  template:
    metadata:
      labels:
        ci.starfleet.io/revision: $REVISION
    spec:
      restartPolicy: Never
      containers:
        - name: check
          image: curlimages/curl:8.22.0
          command: ["sh", "-c"]
          args:
            - test "\$(cat /source/revision)" = "$REVISION" && test -n "\$(cat /source/greeting)"
          volumeMounts:
            - name: source
              mountPath: /source
      volumes:
        - name: source
          configMap:
            name: source
YAML
kubectl -n ci wait --for=condition=complete job/unit-checks --timeout=120s

kubectl -n ci create configmap build-record \
  --from-literal=revision="$REVISION" --from-literal=image="$IMAGE" \
  --from-literal=checks=passed --from-literal=job=unit-checks \
  --dry-run=client -o yaml | kubectl apply -f -

for env in staging production; do
  kubectl -n "$env" create configmap app-config --from-literal=PODINFO_UI_MESSAGE="$env" --dry-run=client -o yaml | kubectl apply -f -
  kubectl -n "$env" apply -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
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
          image: $IMAGE
          ports:
            - name: http
              containerPort: 9898
          envFrom:
            - configMapRef:
                name: app-config
YAML
done
