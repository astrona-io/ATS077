---
estimated_duration: 40m
---

# Lab: Pipeline Fundamentals Capstone

Graded section capstone lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-060/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-060/capstone/labs/lab-01
astrona destroy ats-077-capstone-060
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-pipeline-identities.sh` | The three ServiceAccounts exist in `ci`. `kubectl auth can-i --as` shows that `ci-build` may create and patch ConfigMaps and create Jobs in `ci` but not patch Deployments, and that each deploy account may patch Deployments only in its own namespace, may not delete them, and nobody may read Secrets or touch `starfleet` |
| `validate-release-promotion.sh` | `scout` in `staging` and `production` has the pod template label `release=r2`, the same image as before, an available replica, and production has the change cause `release r2` and a revision of at least 2 |
| `validate-release-record.sh` | `release-record` has `revision` `r2`, `image` equal to the production image, `deployed-revision` equal to the production revision annotation and `previous-revision` one less |
| `validate-workloads-running.sh` | `scout`, `probe` and `shuttle` are available with their original images (passes before any change) |
