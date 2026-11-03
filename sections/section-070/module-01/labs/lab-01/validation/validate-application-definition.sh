#!/usr/bin/env bash
# Check: Argo CD has repository credentials and the Application scout-staging is defined as required.
set -uo pipefail
URL="http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git"
fail=0

secrets="$(kubectl -n argocd get secret -l argocd.argoproj.io/secret-type=repository -o json 2>/dev/null || true)"
match="$(jq -r --arg u "$URL" '[.items[]? | select((.data.url // "" | @base64d) == $u)] | length' <<<"${secrets:-{\}}" 2>/dev/null || echo 0)"
if [ "$match" -lt 1 ]; then
  echo "FAIL: no repository Secret in argocd (label argocd.argoproj.io/secret-type=repository) has the url $URL"
  fail=1
else
  stype="$(jq -r --arg u "$URL" '[.items[] | select((.data.url // "" | @base64d) == $u)][0].data.type // "" | @base64d' <<<"$secrets")"
  if [ "$stype" != "git" ]; then
    echo "FAIL: repository Secret has type '$stype', expected git"
    fail=1
  fi
fi

app="$(kubectl -n argocd get application scout-staging -o json 2>/dev/null || true)"
if [ -z "$app" ]; then
  echo "FAIL: Application scout-staging does not exist in argocd"
  exit 1
fi
chk() { # label jq expected
  local got
  got="$(jq -r "$2" <<<"$app")"
  if [ "$got" != "$3" ]; then
    echo "FAIL: $1 is '$got', expected '$3'"
    fail=1
  fi
}
chk "spec.source.repoURL" '.spec.source.repoURL // ""' "$URL"
chk "spec.source.targetRevision" '.spec.source.targetRevision // ""' "main"
chk "spec.source.path" '.spec.source.path // ""' "overlays/staging"
chk "spec.destination.namespace" '.spec.destination.namespace // ""' "staging"
chk "spec.syncPolicy.automated.prune" '.spec.syncPolicy.automated.prune // false' "true"
chk "spec.syncPolicy.automated.selfHeal" '.spec.syncPolicy.automated.selfHeal // false' "true"
dest="$(jq -r '.spec.destination.server // .spec.destination.name // ""' <<<"$app")"
if [ "$dest" != "https://kubernetes.default.svc" ] && [ "$dest" != "in-cluster" ]; then
  echo "FAIL: destination is '$dest', expected the in-cluster server"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: repository credentials exist and scout-staging is defined with automated prune and selfHeal"
fi
exit "$fail"
