#!/usr/bin/env bash
# Reference solution: promote production with a commit and record the revision.
set -euo pipefail
LOCAL_PORT=$(( 30000 + RANDOM % 20000 ))
kubectl -n gitea port-forward svc/gitea-http "$LOCAL_PORT:3000" >/dev/null 2>&1 &
PF=$!
WORK="$(mktemp -d)"
trap 'kill $PF 2>/dev/null || true; rm -rf "$WORK"' EXIT
for i in $(seq 1 30); do curl -fs "http://127.0.0.1:$LOCAL_PORT/api/v1/version" >/dev/null 2>&1 && break; sleep 1; done
git clone -q "http://platform:starfleet-gitops@127.0.0.1:$LOCAL_PORT/starfleet/scout-deploy.git" "$WORK/repo"
cd "$WORK/repo"
sed -i.bak 's/newTag: 6.14.0/newTag: 6.15.0/' overlays/production/kustomization.yaml
rm overlays/production/kustomization.yaml.bak
git -c user.name=platform -c user.email=platform@starfleet.local commit -q -am "Promote scout to 6.15.0 in production"
git push -q origin main
COMMIT="$(git rev-parse HEAD)"

for i in $(seq 1 90); do
  synced="$(kubectl -n argocd get application scout-production -o jsonpath='{.status.sync.revision}' 2>/dev/null || true)"
  state="$(kubectl -n argocd get application scout-production -o jsonpath='{.status.sync.status}/{.status.health.status}' 2>/dev/null || true)"
  [ "$synced" = "$COMMIT" ] && [ "$state" = "Synced/Healthy" ] && break
  sleep 3
done
kubectl -n production rollout status deployment/scout --timeout=240s
IMAGE="$(kubectl -n production get deployment scout -o jsonpath='{.spec.template.spec.containers[0].image}')"
kubectl -n argocd create configmap promotion-record \
  --from-literal=commit="$COMMIT" \
  --from-literal=synced-revision="$synced" \
  --from-literal=image="$IMAGE" \
  --from-literal=environment=production \
  --dry-run=client -o yaml | kubectl apply -f -
