#!/usr/bin/env bash
# Check: production runs 6.15.0 because Git says so, and Argo CD delivered it.
set -uo pipefail
GIT="http://gitea-http.gitea.svc:3000/api/v1/repos/starfleet/scout-deploy"
fail=0

app="$(kubectl -n argocd get application scout-production -o json 2>/dev/null || true)"
if [ -z "$app" ]; then
  echo "FAIL: Application scout-production does not exist (do not delete it)"
  exit 1
fi
sync="$(jq -r '.status.sync.status // ""' <<<"$app")"
health="$(jq -r '.status.health.status // ""' <<<"$app")"
[ "$sync" = "Synced" ] || { echo "FAIL: scout-production sync status is '$sync', expected Synced"; fail=1; }
[ "$health" = "Healthy" ] || { echo "FAIL: scout-production health status is '$health', expected Healthy"; fail=1; }

image="$(kubectl -n production get deployment scout -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
if [ "$image" != "ghcr.io/stefanprodan/podinfo:6.15.0" ]; then
  echo "FAIL: scout in production runs '$image', expected ghcr.io/stefanprodan/podinfo:6.15.0"
  fail=1
fi

raw="$(kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 10 -u platform:starfleet-gitops "$GIT/raw/overlays/production/kustomization.yaml?ref=main" 2>/dev/null || true)"
if ! grep -q 'newTag: 6.15.0' <<<"$raw"; then
  echo "FAIL: overlays/production/kustomization.yaml on main in Git does not contain newTag: 6.15.0"
  fail=1
fi
if grep -q 'newTag: 6.14.0' <<<"$raw"; then
  echo "FAIL: overlays/production/kustomization.yaml on main in Git still contains newTag: 6.14.0"
  fail=1
fi

replicas="$(kubectl -n production get deployment scout -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
if [ "$replicas" != "2" ]; then
  echo "FAIL: scout in production has $replicas replicas, expected 2 (the value in the overlay)"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: production runs 6.15.0, Git says 6.15.0 and scout-production is Synced and Healthy"
fi
exit "$fail"
