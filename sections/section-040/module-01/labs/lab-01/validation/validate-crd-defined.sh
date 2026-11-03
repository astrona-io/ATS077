#!/usr/bin/env bash
# Check: the CRD has the requested shape.
set -uo pipefail

crd="$(kubectl get crd apprequests.platform.starfleet.io -o json 2>/dev/null || true)"
if [ -z "$crd" ]; then
  echo "FAIL: CRD apprequests.platform.starfleet.io does not exist"
  exit 1
fi

fail=0
chk() {
  local label="$1" want="$2" filter="$3" got
  got="$(jq -r "$filter" <<<"$crd")"
  if [ "$got" != "$want" ]; then
    echo "FAIL: $label is '$got', expected '$want'"
    fail=1
  fi
}
chk group platform.starfleet.io '.spec.group'
chk kind AppRequest '.spec.names.kind'
chk plural apprequests '.spec.names.plural'
chk scope Namespaced '.spec.scope'
chk "version name" v1 '.spec.versions[0].name'
chk served true '.spec.versions[0].served'
chk storage true '.spec.versions[0].storage'
chk "status subresource" true '(.spec.versions[0].subresources.status != null)'
chk established True '[.status.conditions[]? | select(.type=="Established") | .status][0] // "none"'

if [ "$fail" -eq 0 ]; then
  echo "PASS: the CRD is established with the requested shape"
fi
exit "$fail"
