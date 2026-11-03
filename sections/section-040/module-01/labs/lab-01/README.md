---
estimated_duration: 25m
---

# Lab: Custom Resource As A Platform API Lab

Graded module lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-040/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-040/module-01/labs/lab-01
astrona destroy ats-077-lab-040-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-crd-defined.sh` | The CRD exists, is `Established`, has group `platform.starfleet.io`, kind `AppRequest`, scope `Namespaced`, version `v1` served and stored, and the `status` subresource |
| `validate-crd-validation.sh` | Server-side dry runs: two valid objects are accepted; a tier outside the enum, replicas `9` and `0`, a missing name and a `large` request without a contact are rejected |
| `validate-request-accepted.sh` | `scout-request` in `starfleet` has name `scout`, tier `small`, replicas `2` and status phase `Accepted` |
| `validate-workloads-running.sh` | `scout` and `shuttle` are available with their original images (passes before any change) |
