---
estimated_duration: 25m
---

# Lab: GitOps Delivery Lab

Graded module lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The task is in `question.md`; the walkthrough is in `solution.md`. Argo CD is installed from the upstream release manifest at start, so the host needs network access.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-070/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-070/module-01/labs/lab-01
astrona destroy ats-077-lab-070-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-application-definition.sh` | A repository Secret in `argocd` carries the in-cluster URL with type `git`, and the Application `scout-staging` has the right source, path, destination and automated `prune` and `selfHeal` |
| `validate-delivered.sh` | `scout-staging` is `Synced` and `Healthy`, `scout` in `staging` runs 6.15.0 and is tracked by the Application, and a request from `shuttle` returns version 6.15.0 and message `staging` |
| `validate-self-heal.sh` | Scaling `scout` to 3 is reverted to 1 within 90 seconds |
| `validate-workloads-running.sh` | `scout`, `probe` and `shuttle` are available with their original images (passes before any change) |
