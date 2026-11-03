#!/usr/bin/env bash
# Check: the promotion went through Git, not around it.
set -uo pipefail
fail=0
for app in scout-staging scout-production; do
  json="$(kubectl -n argocd get application "$app" -o json 2>/dev/null || true)"
  if [ -z "$json" ]; then
    echo "FAIL: Application $app does not exist"
    fail=1
    continue
  fi
  heal="$(jq -r '.spec.syncPolicy.automated.selfHeal // false' <<<"$json")"
  prune="$(jq -r '.spec.syncPolicy.automated.prune // false' <<<"$json")"
  rev="$(jq -r '.spec.source.targetRevision // ""' <<<"$json")"
  if [ "$heal" != "true" ] || [ "$prune" != "true" ] || [ "$rev" != "main" ]; then
    echo "FAIL: $app must keep automated prune and selfHeal on main (prune=$prune selfHeal=$heal targetRevision=$rev)"
    fail=1
  fi
done
img="$(kubectl -n staging get deployment scout -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
if [ "$img" != "ghcr.io/stefanprodan/podinfo:6.15.0" ]; then
  echo "FAIL: scout in staging runs '$img', expected ghcr.io/stefanprodan/podinfo:6.15.0"
  fail=1
fi
tracking="$(kubectl -n production get deployment scout -o jsonpath='{.metadata.annotations.argocd\.argoproj\.io/tracking-id}' 2>/dev/null || true)"
case "$tracking" in
  scout-production:*) ;;
  *) echo "FAIL: scout in production is not tracked by scout-production (tracking-id '$tracking')"; fail=1 ;;
esac
if [ "$fail" -eq 0 ]; then
  echo "PASS: both Applications keep automated sync and scout in production is still owned by scout-production"
fi
exit "$fail"
