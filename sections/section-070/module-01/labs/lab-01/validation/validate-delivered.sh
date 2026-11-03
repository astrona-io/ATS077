#!/usr/bin/env bash
# Check: the controller delivered the overlay, and the result is visible in the cluster.
set -uo pipefail
fail=0

app="$(kubectl -n argocd get application scout-staging -o json 2>/dev/null || true)"
if [ -z "$app" ]; then
  echo "FAIL: Application scout-staging does not exist"
  exit 1
fi
sync="$(jq -r '.status.sync.status // ""' <<<"$app")"
health="$(jq -r '.status.health.status // ""' <<<"$app")"
if [ "$sync" != "Synced" ]; then
  echo "FAIL: sync status is '$sync', expected Synced"
  fail=1
fi
if [ "$health" != "Healthy" ]; then
  echo "FAIL: health status is '$health', expected Healthy"
  fail=1
fi

dep="$(kubectl -n staging get deployment scout -o json 2>/dev/null || true)"
if [ -z "$dep" ]; then
  echo "FAIL: Deployment scout does not exist in staging"
  exit 1
fi
image="$(jq -r '.spec.template.spec.containers[0].image' <<<"$dep")"
if [ "$image" != "ghcr.io/stefanprodan/podinfo:6.15.0" ]; then
  echo "FAIL: scout in staging runs '$image', expected ghcr.io/stefanprodan/podinfo:6.15.0"
  fail=1
fi
tracking="$(jq -r '.metadata.annotations["argocd.argoproj.io/tracking-id"] // ""' <<<"$dep")"
case "$tracking" in
  scout-staging:*) ;;
  *) echo "FAIL: Deployment scout is not tracked by scout-staging (tracking-id '$tracking'); apply it through the Application, not with kubectl"; fail=1 ;;
esac

body="$(kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 10 http://scout.staging/ 2>/dev/null || true)"
version="$(jq -r '.version // ""' <<<"${body:-{\}}" 2>/dev/null || true)"
message="$(jq -r '.message // ""' <<<"${body:-{\}}" 2>/dev/null || true)"
if [ "$version" != "6.15.0" ] || [ "$message" != "staging" ]; then
  echo "FAIL: a request from shuttle to http://scout.staging/ returned version '$version' and message '$message', expected 6.15.0 and staging"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: scout-staging is Synced and Healthy and scout answers from the staging namespace"
fi
exit "$fail"
