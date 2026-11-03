#!/usr/bin/env bash
# Check: outpost enforces restricted and the running drifter pod complies.
set -uo pipefail

fail=0
label="$(kubectl get namespace outpost -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}' 2>/dev/null || true)"
if [ "$label" != "restricted" ]; then
  echo "FAIL: namespace outpost has enforce='${label:-none}', expected 'restricted'"
  fail=1
fi
pods="$(kubectl -n outpost get pods -l app=drifter -o json)"
running="$(echo "$pods" | jq '[.items[] | select(.metadata.deletionTimestamp == null) | select(.status.phase == "Running")] | length')"
if [ "$running" -lt 1 ]; then
  echo "FAIL: no running drifter pod in outpost"
  exit 1
fi
bad="$(echo "$pods" | jq -r '
  .items[] | select(.metadata.deletionTimestamp == null) | select(.status.phase == "Running")
  | select(
      ((.spec.securityContext.runAsNonRoot // .spec.containers[0].securityContext.runAsNonRoot) != true)
      or ((.spec.securityContext.runAsUser // .spec.containers[0].securityContext.runAsUser // 0) == 0)
      or ((.spec.securityContext.seccompProfile.type // .spec.containers[0].securityContext.seccompProfile.type // "") != "RuntimeDefault")
      or (.spec.containers[0].securityContext.allowPrivilegeEscalation != false)
      or (((.spec.containers[0].securityContext.capabilities.drop // []) | index("ALL")) == null)
      or (.metadata.labels.owner != "drifter-team")
    )
  | .metadata.name')"
if [ -n "$bad" ]; then
  echo "FAIL: pod $bad is not compliant or has no owner=drifter-team label; roll out the fixed Deployment"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: outpost enforces restricted and drifter complies and is owned"
fi
exit "$fail"
