---
estimated_duration: 40m
---

# Lab: DevOps Practices Capstone

Graded section capstone lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-020/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-020/capstone/labs/lab-01
astrona destroy ats-077-capstone-020
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-probe-recovered.sh` | `probe` has image `mccutchen/go-httpbin:2.25.0`, a readiness probe with an `httpGet` handler, and all replicas updated and available |
| `validate-outpost-restricted.sh` | `outpost` has `enforce=restricted`; the running `drifter` pod is non-root with a numeric user, seccomp `RuntimeDefault`, no privilege escalation, all capabilities dropped, and `owner=drifter-team` |
| `validate-team-access.sh` | `can-i` answers for the group `drifter-team`: update Deployments in `outpost` yes; delete Deployments, read Secrets and update Deployments in `starfleet` no |
| `validate-workloads-running.sh` | `scout` and `shuttle` are available with their original images (passes before any change) |
