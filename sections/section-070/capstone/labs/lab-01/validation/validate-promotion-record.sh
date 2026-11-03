#!/usr/bin/env bash
# Check: the promotion record ties the Git commit to the revision Argo CD reached.
set -uo pipefail
GIT="http://gitea-http.gitea.svc:3000/api/v1/repos/starfleet/scout-deploy"
fail=0

cm="$(kubectl -n argocd get configmap promotion-record -o json 2>/dev/null || true)"
if [ -z "$cm" ]; then
  echo "FAIL: ConfigMap promotion-record does not exist in argocd"
  exit 1
fi
key() { jq -r --arg k "$1" '.data[$k] // ""' <<<"$cm"; }

head="$(kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 10 -u platform:starfleet-gitops "$GIT/branches/main" 2>/dev/null | jq -r '.commit.id // ""' 2>/dev/null || true)"
synced="$(kubectl -n argocd get application scout-production -o jsonpath='{.status.sync.revision}' 2>/dev/null || true)"
image="$(kubectl -n production get deployment scout -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"

if [ -z "$head" ]; then
  echo "FAIL: could not read the head of main from the Git server"
  exit 1
fi
if [ "$head" != "$synced" ]; then
  echo "FAIL: Argo CD synced '$synced' but main is at '$head'; wait for the controller to reach the commit"
  fail=1
fi
[ "$(key commit)" = "$head" ] || { echo "FAIL: key commit is '$(key commit)', expected the head of main '$head'"; fail=1; }
[ "$(key synced-revision)" = "$synced" ] || { echo "FAIL: key synced-revision is '$(key synced-revision)', expected '$synced'"; fail=1; }
[ "$(key image)" = "$image" ] || { echo "FAIL: key image is '$(key image)', expected '$image'"; fail=1; }
[ "$(key environment)" = "production" ] || { echo "FAIL: key environment is '$(key environment)', expected production"; fail=1; }

if [ "$fail" -eq 0 ]; then
  echo "PASS: promotion-record names the commit that Git and Argo CD agree on"
fi
exit "$fail"
