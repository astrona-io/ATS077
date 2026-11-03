---
estimated_duration: 25m
---

# Lab: Declare, Render And Apply Under A Field Manager

Graded module lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-010/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-010/module-01/labs/lab-01
astrona destroy ats-077-lab-010-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-debug-pod-managed.sh` | Deployment `shuttle-debug` has 2 available replicas and every `shuttle-debug` pod has a ReplicaSet owner |
| `validate-outpost-scout-rendered.sh` | `outpost-scout` exists in `outpost` with 2 replicas, the `tier: edge` label on object, selector and pod template, and the original image |
| `validate-field-manager.sh` | `metadata.managedFields` of `outpost-scout` contains the manager `platform-team` |
| `validate-workloads-running.sh` | The three starting Deployments are available with their original images (passes before any change) |
