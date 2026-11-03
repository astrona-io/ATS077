---
estimated_duration: 25m
---

# Lab: Ownership, Probes And A Restricted Namespace

Graded module lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-020/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-020/module-01/labs/lab-01
astrona destroy ats-077-lab-020-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-owner-labels.sh` | The running (not terminating) pods of `scout`, `probe` and `shuttle` carry `owner=bridge-team` |
| `validate-probe-readiness.sh` | The `probe` container has a `readinessProbe` with an `httpGet` handler and the Deployment is available |
| `validate-sandbox-restricted.sh` | Namespace `sandbox` has `pod-security.kubernetes.io/enforce=restricted` and a running `crew` pod has the compliant security settings |
| `validate-workloads-running.sh` | The three Deployments are available with their original images (passes before any change) |
