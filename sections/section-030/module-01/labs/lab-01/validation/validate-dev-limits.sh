#!/usr/bin/env bash
# Check: dev has the quota and the default limits.
set -uo pipefail

fail=0
quota="$(kubectl -n dev get resourcequota dev-quota -o json 2>/dev/null || true)"
if [ -z "$quota" ]; then
  echo "FAIL: ResourceQuota dev-quota does not exist in dev"
  fail=1
else
  for pair in 'pods=4' 'requests.memory=256Mi' 'limits.memory=512Mi'; do
    key="${pair%%=*}"; want="${pair#*=}"
    got="$(jq -r --arg k "$key" '.spec.hard[$k] // ""' <<<"$quota")"
    if [ "$got" != "$want" ]; then
      echo "FAIL: dev-quota hard $key is '$got', expected '$want'"
      fail=1
    fi
  done
fi

lr="$(kubectl -n dev get limitrange dev-defaults -o json 2>/dev/null || true)"
if [ -z "$lr" ]; then
  echo "FAIL: LimitRange dev-defaults does not exist in dev"
  fail=1
else
  dflt="$(jq -r '[.spec.limits[] | select(.type=="Container") | .default.memory][0] // ""' <<<"$lr")"
  req="$(jq -r '[.spec.limits[] | select(.type=="Container") | .defaultRequest.memory][0] // ""' <<<"$lr")"
  [ "$dflt" = "64Mi" ] || { echo "FAIL: LimitRange default memory is '$dflt', expected '64Mi'"; fail=1; }
  [ "$req" = "16Mi" ] || { echo "FAIL: LimitRange defaultRequest memory is '$req', expected '16Mi'"; fail=1; }
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: dev has the quota and the default limits"
fi
exit "$fail"
