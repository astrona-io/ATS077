#!/usr/bin/env bash
# Check: the namespace enforces restricted and the running crew pod is compliant.
set -uo pipefail

fail=0
label="$(kubectl get namespace sandbox -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}' 2>/dev/null || true)"
if [ "$label" != "restricted" ]; then
  echo "FAIL: namespace sandbox has enforce='${label:-none}', expected 'restricted'"
  fail=1
fi

pods="$(kubectl -n sandbox get pods -l app=crew -o json)"
running="$(echo "$pods" | jq '[.items[] | select(.metadata.deletionTimestamp == null) | select(.status.phase == "Running")] | length')"
if [ "$running" -lt 1 ]; then
  echo "FAIL: no running crew pod in sandbox"
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
    )
  | .metadata.name')"
if [ -n "$bad" ]; then
  echo "FAIL: pod $bad does not meet the restricted settings; roll out the fixed Deployment"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: sandbox enforces restricted and crew runs with a compliant security context"
fi
exit "$fail"
