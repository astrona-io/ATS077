#!/usr/bin/env bash
# Check: release r2 reached both environments as the same artifact.
set -uo pipefail

fail=0
for env in staging production; do
  dep="$(kubectl -n "$env" get deployment scout -o json 2>/dev/null || true)"
  if [ -z "$dep" ]; then
    echo "FAIL: deployment scout does not exist in $env"
    fail=1
    continue
  fi
  rel="$(jq -r '.spec.template.metadata.labels.release // ""' <<<"$dep")"
  if [ "$rel" != "r2" ]; then
    echo "FAIL: scout in $env has template label release='$rel', expected 'r2'"
    fail=1
  fi
  img="$(jq -r '.spec.template.spec.containers[0].image' <<<"$dep")"
  if [ "$img" != "ghcr.io/stefanprodan/podinfo:6.15.0" ]; then
    echo "FAIL: scout in $env runs '$img', the artifact must not change"
    fail=1
  fi
  avail="$(jq -r '.status.availableReplicas // 0' <<<"$dep")"
  if [ "$avail" -lt 1 ]; then
    echo "FAIL: scout in $env has no available replica"
    fail=1
  fi
done

prod="$(kubectl -n production get deployment scout -o json 2>/dev/null || true)"
if [ -n "$prod" ]; then
  cause="$(jq -r '.metadata.annotations["kubernetes.io/change-cause"] // ""' <<<"$prod")"
  if [ "$cause" != "release r2" ]; then
    echo "FAIL: production change-cause is '$cause', expected 'release r2'"
    fail=1
  fi
  rev="$(jq -r '.metadata.annotations["deployment.kubernetes.io/revision"] // "0"' <<<"$prod")"
  if [ "$rev" -lt 2 ]; then
    echo "FAIL: production is still at revision $rev, expected a new revision"
    fail=1
  fi
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: release r2 runs in staging and production with the same image"
fi
exit "$fail"
