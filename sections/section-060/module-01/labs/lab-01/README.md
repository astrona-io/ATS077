---
estimated_duration: 25m
---

# Lab: Pipeline Stages And Promotion

Graded module lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-060/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-060/module-01/labs/lab-01
astrona destroy ats-077-lab-060-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-check-stage.sh` | The Job `unit-checks` in `ci` has `succeeded` 1, carries the label `ci.starfleet.io/revision` equal to the revision in the ConfigMap `source`, and mounts that ConfigMap as a volume |
| `validate-build-record.sh` | The ConfigMap `build-record` in `ci` has `revision` equal to the source revision, `image` equal to the pinned podinfo image, `checks` equal to `passed` and `job` equal to `unit-checks` |
| `validate-promotion.sh` | `scout` in `staging` and `production` runs the image from the build record (not a `latest` tag), reads `app-config` through `envFrom` with `PODINFO_UI_MESSAGE` equal to the namespace name, and has an available replica |
| `validate-workloads-running.sh` | `scout`, `probe` and `shuttle` are available with their original images (passes before any change) |
