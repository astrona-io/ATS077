#!/usr/bin/env bash
# Check: the check stage ran as a Job, against the current source revision.
set -uo pipefail

rev="$(kubectl -n ci get configmap source -o jsonpath='{.data.revision}' 2>/dev/null || true)"
if [ -z "$rev" ]; then
  echo "FAIL: ConfigMap source in ci has no revision (do not delete it)"
  exit 1
fi

job="$(kubectl -n ci get job unit-checks -o json 2>/dev/null || true)"
if [ -z "$job" ]; then
  echo "FAIL: Job unit-checks does not exist in ci"
  exit 1
fi

fail=0
succeeded="$(jq -r '.status.succeeded // 0' <<<"$job")"
if [ "$succeeded" != "1" ]; then
  echo "FAIL: Job unit-checks has succeeded=$succeeded, expected 1"
  fail=1
fi
label="$(jq -r '.metadata.labels["ci.starfleet.io/revision"] // ""' <<<"$job")"
if [ "$label" != "$rev" ]; then
  echo "FAIL: label ci.starfleet.io/revision is '$label', expected '$rev'"
  fail=1
fi
mounts="$(jq -r '[.spec.template.spec.volumes[]? | select(.configMap.name == "source")] | length' <<<"$job")"
if [ "$mounts" -lt 1 ]; then
  echo "FAIL: Job unit-checks does not mount the ConfigMap source"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: unit-checks succeeded for revision $rev and reads the source"
fi
exit "$fail"
