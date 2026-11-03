---
estimated_duration: 40m
---

# Lab: Environment Boundaries Capstone

Graded section capstone lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-030/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-030/capstone/labs/lab-01
astrona destroy ats-077-capstone-030
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-environment-guardrails.sh` | Namespaces `dev`, `test` and `prod` have `environment=<name>`; `prod` has `pod-security.kubernetes.io/enforce=restricted` and `dev` and `test` do not; `test-quota` in `test` has pods `5` |
| `validate-environment-access.sh` | `can-i` answers for the group `drifter-team`: create Deployments in `dev` and `test` yes; get pods in `prod` yes; create Deployments, update Deployments and get Secrets in `prod` no |
| `validate-data-separation.sh` | `test` `DATABASE_HOST` is set and not the production host; the `db-credentials` password in `test` differs from `prod`; `prod` host and password are unchanged |
| `validate-workloads-running.sh` | `scout` and `shuttle` are available with their original images (passes before any change) |
