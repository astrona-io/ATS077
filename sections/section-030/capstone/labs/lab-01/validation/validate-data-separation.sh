#!/usr/bin/env bash
# Check: test has its own host and password, and prod was not touched.
set -uo pipefail

fail=0
host() { kubectl -n "$1" get configmap app-config -o jsonpath='{.data.DATABASE_HOST}' 2>/dev/null || true; }
pass() { kubectl -n "$1" get secret db-credentials -o jsonpath='{.data.password}' 2>/dev/null || true; }

host_test="$(host test)"; host_prod="$(host prod)"
pass_test="$(pass test)"; pass_prod="$(pass prod)"

if [ -z "$host_test" ] || [ "$host_test" = "$host_prod" ]; then
  echo "FAIL: test DATABASE_HOST is '$host_test'; it must be set and not the production host"
  fail=1
fi
if [ -z "$pass_test" ] || [ "$pass_test" = "$pass_prod" ]; then
  echo "FAIL: the db-credentials password in test is missing or equal to production"
  fail=1
fi
[ "$host_prod" = "db.prod.starfleet.internal" ] || { echo "FAIL: the production DATABASE_HOST was changed"; fail=1; }
[ "$(printf '%s' "$pass_prod" | base64 -d 2>/dev/null)" = "prod-only-value" ] || { echo "FAIL: the production password was changed"; fail=1; }

if [ "$fail" -eq 0 ]; then
  echo "PASS: test has its own host and password and prod is unchanged"
fi
exit "$fail"
