---
estimated_duration: 40m
---

# Lab: Platform Goals Capstone

Graded section capstone lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-050/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-050/capstone/labs/lab-01
astrona destroy ats-077-capstone-050
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-engine-on-path.sh` | `engine-web` in `adopt` has the path label on the Deployment and the pod template, a readiness probe, requests, a memory limit, the restricted security settings, the original podinfo image and an available replica |
| `validate-exception-recorded.sh` | `drifter-web` has the label `platform.starfleet.io/path=exception`, a non-empty `exception-reason` annotation and a non-empty `exception-review` annotation |
| `validate-adoption-report.sh` | The ConfigMap `adoption-report` in `adopt` has `onpath`, `exceptions` and `total` equal to the counts derived from the cluster, and those counts are `2`, `1` and `3` |
| `validate-workloads-running.sh` | `scout`, `probe` and `shuttle` are available with their original images (passes before any change) |
