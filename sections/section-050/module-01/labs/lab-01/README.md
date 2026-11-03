---
estimated_duration: 25m
---

# Lab: Golden Path Base For Two Teams

Graded module lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-050/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-050/module-01/labs/lab-01
astrona destroy ats-077-lab-050-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-golden-defaults.sh` | `web` in `bridge` and `engine` uses podinfo 6.15.0, has a readiness probe, CPU and memory requests, a memory limit, `runAsNonRoot`, `runAsUser` 1000, `RuntimeDefault` seccomp, no privilege escalation, `drop: ALL`, and the label `platform.starfleet.io/path=golden` on the Deployment and the pod template |
| `validate-team-overlays.sh` | `bridge` has 2 replicas and `engine` has 1; the label `team` equals the namespace on the Deployment and the pod template; a Service `web` exists in both |
| `validate-services-ready.sh` | The EndpointSlices of `web` hold one ready endpoint for each replica (waits up to 90 seconds) |
| `validate-workloads-running.sh` | `scout`, `probe` and `shuttle` are available with their original images (passes before any change) |
