#!/usr/bin/env bash
# Check: the schema accepts good requests and rejects bad ones. Server-side dry run only.
set -uo pipefail

fail=0
try() {
  local want="$1" label="$2" spec="$3"
  local out rc
  out="$(printf 'apiVersion: platform.starfleet.io/v1\nkind: AppRequest\nmetadata:\n  name: grader-probe\n  namespace: starfleet\nspec:\n%s\n' "$spec" | kubectl create --dry-run=server -f - 2>&1)"
  rc=$?
  if [ "$want" = "accept" ] && [ "$rc" -ne 0 ]; then
    echo "FAIL: '$label' was rejected: $out"
    fail=1
  elif [ "$want" = "reject" ] && [ "$rc" -eq 0 ]; then
    echo "FAIL: '$label' was accepted but should be rejected"
    fail=1
  fi
}

if ! kubectl get crd apprequests.platform.starfleet.io >/dev/null 2>&1; then
  echo "FAIL: CRD apprequests.platform.starfleet.io does not exist"
  exit 1
fi

try accept "small with replicas" "$(printf '  name: scout\n  tier: small\n  replicas: 2')"
try accept "large with contact" "$(printf '  name: scout\n  tier: large\n  contact: bridge')"
try reject "tier outside the enum" "$(printf '  name: scout\n  tier: huge')"
try reject "replicas above 5" "$(printf '  name: scout\n  tier: small\n  replicas: 9')"
try reject "replicas below 1" "$(printf '  name: scout\n  tier: small\n  replicas: 0')"
try reject "missing name" "$(printf '  tier: small')"
try reject "large without contact" "$(printf '  name: scout\n  tier: large')"

if [ "$fail" -eq 0 ]; then
  echo "PASS: the schema accepts good requests and rejects bad ones"
fi
exit "$fail"
