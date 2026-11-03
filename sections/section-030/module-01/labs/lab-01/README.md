---
estimated_duration: 25m
---

# Lab: Quota, Defaults And Parity Lab

Graded module lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-030/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-030/module-01/labs/lab-01
astrona destroy ats-077-lab-030-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-dev-limits.sh` | `dev-quota` has pods `4`, requests.memory `256Mi`, limits.memory `512Mi`; `dev-defaults` is a Container LimitRange with default memory `64Mi` and defaultRequest memory `16Mi` |
| `validate-dev-workload.sh` | `crew` in `dev` has two available replicas, the podinfo image, no resources in its template, and every `crew` pod has memory limit `64Mi` |
| `validate-config-parity.sh` | The key sets of the three `app-config` ConfigMaps are equal, `ENVIRONMENT` matches the namespace, prod `LOG_LEVEL` is `warn`, test `DATABASE_HOST` is set and not the production host |
| `validate-workloads-running.sh` | `scout` and `shuttle` are available with their original images (passes before any change) |
