#!/usr/bin/env bash
# Check: both environments run the artifact named in the build record.
set -uo pipefail

image="$(kubectl -n ci get configmap build-record -o jsonpath='{.data.image}' 2>/dev/null || true)"
if [ -z "$image" ]; then
  echo "FAIL: the build record has no image to promote"
  exit 1
fi

fail=0
for env in staging production; do
  dep="$(kubectl -n "$env" get deployment scout -o json 2>/dev/null || true)"
  if [ -z "$dep" ]; then
    echo "FAIL: deployment scout does not exist in $env"
    fail=1
    continue
  fi
  got="$(jq -r '.spec.template.spec.containers[0].image' <<<"$dep")"
  if [ "$got" != "$image" ]; then
    echo "FAIL: scout in $env runs '$got', the build record says '$image'"
    fail=1
  fi
  if [ "${got##*:}" = "latest" ]; then
    echo "FAIL: scout in $env uses a latest tag"
    fail=1
  fi
  ref="$(jq -r '[.spec.template.spec.containers[0].envFrom[]? | select(.configMapRef.name == "app-config")] | length' <<<"$dep")"
  if [ "$ref" -lt 1 ]; then
    echo "FAIL: scout in $env does not read app-config through envFrom"
    fail=1
  fi
  msg="$(kubectl -n "$env" get configmap app-config -o jsonpath='{.data.PODINFO_UI_MESSAGE}' 2>/dev/null || true)"
  if [ "$msg" != "$env" ]; then
    echo "FAIL: app-config in $env has PODINFO_UI_MESSAGE '$msg', expected '$env'"
    fail=1
  fi
  avail="$(jq -r '.status.availableReplicas // 0' <<<"$dep")"
  if [ "$avail" -lt 1 ]; then
    echo "FAIL: scout in $env has no available replica"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: staging and production run $image with their own configuration"
fi
exit "$fail"
