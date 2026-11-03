#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

for name in scout probe shuttle; do
  kubectl -n starfleet patch deployment "$name" --type=merge \
    -p '{"spec":{"template":{"metadata":{"labels":{"owner":"bridge-team"}}}}}'
done

kubectl -n starfleet patch deployment probe --type=strategic -p '{
  "spec":{"template":{"spec":{"containers":[{"name":"probe","readinessProbe":{"httpGet":{"path":"/status/200","port":"http"},"periodSeconds":5}}]}}}}'

kubectl label namespace sandbox pod-security.kubernetes.io/enforce=restricted
kubectl -n sandbox patch deployment crew --type=strategic -p '{
  "spec":{"template":{"spec":{
    "securityContext":{"runAsNonRoot":true,"runAsUser":1000,"seccompProfile":{"type":"RuntimeDefault"}},
    "containers":[{"name":"crew","securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}}]}}}}'
echo "[solution] Applied."
