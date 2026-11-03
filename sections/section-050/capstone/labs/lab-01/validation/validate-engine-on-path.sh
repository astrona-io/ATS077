#!/usr/bin/env bash
# Check: engine-web meets every golden path setting and still runs.
set -uo pipefail

dep="$(kubectl -n adopt get deployment engine-web -o json 2>/dev/null || true)"
if [ -z "$dep" ]; then
  echo "FAIL: deployment engine-web does not exist in adopt"
  exit 1
fi

problems="$(jq -r '
  . as $d | $d.spec.template.spec as $p | $p.containers[0] as $c |
  [
    (if $c.image != "ghcr.io/stefanprodan/podinfo:6.15.0" then "image is \($c.image)" else empty end),
    (if $c.readinessProbe == null then "no readiness probe" else empty end),
    (if ($c.resources.requests.cpu // "") == "" or ($c.resources.requests.memory // "") == "" then "cpu and memory requests are required" else empty end),
    (if ($c.resources.limits.memory // "") == "" then "memory limit is missing" else empty end),
    (if $p.securityContext.runAsNonRoot != true then "runAsNonRoot is not true" else empty end),
    (if $p.securityContext.seccompProfile.type != "RuntimeDefault" then "seccomp profile is not RuntimeDefault" else empty end),
    (if $c.securityContext.allowPrivilegeEscalation != false then "allowPrivilegeEscalation is not false" else empty end),
    (if (($c.securityContext.capabilities.drop // []) | index("ALL")) == null then "capabilities do not drop ALL" else empty end),
    (if $d.metadata.labels["platform.starfleet.io/path"] != "golden" then "Deployment lacks the path label" else empty end),
    (if $d.spec.template.metadata.labels["platform.starfleet.io/path"] != "golden" then "pod template lacks the path label" else empty end),
    (if ($d.status.availableReplicas // 0) < 1 then "no available replica" else empty end)
  ] | .[]' <<<"$dep")"

if [ -n "$problems" ]; then
  while IFS= read -r line; do
    echo "FAIL: engine-web: $line"
  done <<<"$problems"
  exit 1
fi
echo "PASS: engine-web meets the golden path settings and is available"
