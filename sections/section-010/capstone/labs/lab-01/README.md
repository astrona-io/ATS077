---
estimated_duration: 40m
---

# Lab: Declarative Resource Management Capstone

Graded section capstone lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-010/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-010/capstone/labs/lab-01
astrona destroy ats-077-capstone-010
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-shuttle-drift-removed.sh` | `shuttle` has `spec.replicas` 1 and `platform-team` (operation Apply) owns the field |
| `validate-outpost-rendered.sh` | `outpost-scout` (2 replicas) and `outpost-probe` (1 replica) exist with `team: drifter` on object, selector and template, and CPU and memory requests |
| `validate-debug-pod-managed.sh` | `drifter-debug` has an available Deployment replica and no pod without a ReplicaSet owner |
| `validate-rollout-evidence.sh` | The ConfigMap `rollout-evidence` matches the live `metadata.generation`, `status.observedGeneration` and `status.readyReplicas` of `outpost-scout` |
| `validate-workloads-running.sh` | The three starting Deployments are available with their original images |
