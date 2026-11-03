---
estimated_duration: 40m
---

# Lab: GitOps And Deployment Capstone

Graded section capstone lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The task is in `question.md`; the walkthrough is in `solution.md`. Argo CD is installed from the upstream release manifest at start, so the host needs network access. The Git server is forwarded to `http://127.0.0.1:3000`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-070/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-070/capstone/labs/lab-01
astrona destroy ats-077-capstone-070
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-production-promoted.sh` | `main` in Git declares `newTag: 6.15.0` for production, `scout-production` is `Synced` and `Healthy`, production runs 6.15.0 with 2 replicas |
| `validate-promotion-record.sh` | The ConfigMap `promotion-record` in `argocd` has `commit` equal to the head of `main` (read through the Gitea API), `synced-revision` equal to `.status.sync.revision`, `image` equal to the production image and `environment` equal to `production` |
| `validate-applications-intact.sh` | Both Applications keep automated `prune` and `selfHeal` on `main`, staging stays at 6.15.0 and production is still tracked by `scout-production` |
| `validate-workloads-running.sh` | `scout`, `probe` and `shuttle` are available with their original images (passes before any change) |
