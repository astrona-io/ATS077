---
estimated_duration: 40m
---

# Lab: Platform Architecture Capstone

Graded section capstone lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-040/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-040/capstone/labs/lab-01
astrona destroy ats-077-capstone-040
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-replica-cap-policy.sh` | The policy `starfleet-replica-cap` has `failurePolicy: Fail`; the binding `starfleet-replica-cap-binding` has the `Deny` action; `starfleet` has `platform=managed`; a server-side dry run of 4 replicas is rejected in `starfleet` and accepted in `outpost`, and 2 replicas is accepted in `starfleet` (retried for up to 60 seconds) |
| `validate-team-submit-access.sh` | `can-i` for the group `drifter-team`: create and get AppRequests in `outpost` yes; create in `starfleet`, update, delete and update of the status subresource in `outpost` no |
| `validate-controller-access.sh` | `can-i` for `system:serviceaccount:starfleet:apprequest-controller`: get AppRequests and update their status in `outpost` yes; create and delete AppRequests no |
| `validate-workloads-running.sh` | `scout` and `shuttle` are available with their original images (passes before any change) |
