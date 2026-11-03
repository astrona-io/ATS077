#!/usr/bin/env bash
# Check: same keys in every environment, values that belong to each.
set -uo pipefail

fail=0
cm() { kubectl -n "$1" get configmap app-config -o json 2>/dev/null || true; }
dev="$(cm dev)"; test_="$(cm test)"; prod="$(cm prod)"
if [ -z "$dev" ] || [ -z "$test_" ] || [ -z "$prod" ]; then
  echo "FAIL: app-config is missing in one of dev, test or prod"
  exit 1
fi

keys() { jq -r '.data | keys | join(",")' <<<"$1"; }
k_dev="$(keys "$dev")"; k_test="$(keys "$test_")"; k_prod="$(keys "$prod")"
if [ "$k_dev" != "$k_test" ] || [ "$k_dev" != "$k_prod" ]; then
  echo "FAIL: key sets differ: dev=[$k_dev] test=[$k_test] prod=[$k_prod]"
  fail=1
fi

for pair in "dev:$dev" "test:$test_" "prod:$prod"; do
  ns="${pair%%:*}"; json="${pair#*:}"
  got="$(jq -r '.data.ENVIRONMENT // ""' <<<"$json")"
  [ "$got" = "$ns" ] || { echo "FAIL: ENVIRONMENT in $ns is '$got'"; fail=1; }
done

level="$(jq -r '.data.LOG_LEVEL // ""' <<<"$prod")"
[ "$level" = "warn" ] || { echo "FAIL: prod LOG_LEVEL is '$level', expected 'warn'"; fail=1; }

host_test="$(jq -r '.data.DATABASE_HOST // ""' <<<"$test_")"
host_prod="$(jq -r '.data.DATABASE_HOST // ""' <<<"$prod")"
if [ -z "$host_test" ]; then
  echo "FAIL: test has no DATABASE_HOST"
  fail=1
elif [ "$host_test" = "$host_prod" ]; then
  echo "FAIL: test uses the production database host"
  fail=1
fi
[ "$host_prod" = "db.prod.starfleet.internal" ] || { echo "FAIL: the production DATABASE_HOST was changed"; fail=1; }

if [ "$fail" -eq 0 ]; then
  echo "PASS: the environments have the same keys and their own values"
fi
exit "$fail"
