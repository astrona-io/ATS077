#!/usr/bin/env bash
# Check: the report matches what the cluster shows, not a guess.
set -uo pipefail

deps="$(kubectl -n adopt get deployments -o json 2>/dev/null || true)"
if [ -z "$deps" ]; then
  echo "FAIL: cannot read the Deployments in adopt"
  exit 1
fi

onpath="$(jq '[.items[]
  | select(.metadata.labels["platform.starfleet.io/path"] == "golden")
  | .spec.template.spec as $p | $p.containers[0] as $c
  | select($c.readinessProbe != null
      and ($c.resources.limits.memory // "") != ""
      and ($c.resources.requests.memory // "") != ""
      and $p.securityContext.runAsNonRoot == true
      and $c.securityContext.allowPrivilegeEscalation == false)] | length' <<<"$deps")"
exceptions="$(jq '[.items[]
  | select(.metadata.labels["platform.starfleet.io/path"] == "exception")
  | select((.metadata.annotations["platform.starfleet.io/exception-reason"] // "") != "")] | length' <<<"$deps")"
total="$(jq '.items | length' <<<"$deps")"

cm="$(kubectl -n adopt get configmap adoption-report -o json 2>/dev/null || true)"
if [ -z "$cm" ]; then
  echo "FAIL: ConfigMap adoption-report does not exist in adopt"
  exit 1
fi

fail=0
cmp_key() {
  local key="$1" derived="$2" got
  got="$(jq -r ".data.$key // \"\"" <<<"$cm")"
  if [ "$got" != "$derived" ]; then
    echo "FAIL: adoption-report $key is '$got', the cluster shows '$derived'"
    fail=1
  fi
}
cmp_key onpath "$onpath"
cmp_key exceptions "$exceptions"
cmp_key total "$total"

if [ "$onpath" != "2" ] || [ "$exceptions" != "1" ] || [ "$total" != "3" ]; then
  echo "FAIL: the cluster shows onpath=$onpath exceptions=$exceptions total=$total, expected 2, 1 and 3 (finish the other tasks first)"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: adoption-report matches the cluster (onpath=2, exceptions=1, total=3)"
fi
exit "$fail"
