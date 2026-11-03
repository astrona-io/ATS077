---
draft: true
exam_objectives:
- Platform Engineering Goals, Objectives, and Approaches
---
# Adoption, Feedback And Exceptions

A golden path is valuable only when teams use it. Teams use it when it is easier than the alternative and when it does not trap them. This part covers how a platform team makes adoption visible, how it handles a workload that cannot follow the path, and how it uses what it learns to improve the path in small steps instead of one large change.

## Adoption is optional by design

A path that is a mandate produces compliance on paper and workarounds in practice. A path that is optional must earn its use by being faster and safer than doing the work alone. The platform team still needs to know where the path is in use, which means that the path must leave a trace on the objects. The label `platform.starfleet.io/path` is that trace.

Start from the playground state, where no workload is on the path. Mark `scout` and `probe` as on the path, in the labels of the Deployment and of its pod template so that pods carry it too:

<!-- astrona:playground:renew -->

```sh
for d in scout probe; do
  kubectl -n starfleet label deployment $d platform.starfleet.io/path=golden
  kubectl -n starfleet patch deployment $d --type=merge -p '{"spec":{"template":{"metadata":{"labels":{"platform.starfleet.io/path":"golden"}}}}}'
done
kubectl -n starfleet rollout status deployment/scout
kubectl -n starfleet rollout status deployment/probe
```

Each `label` command prints `deployment.apps/<name> labeled`, and each `patch` prints `deployment.apps/<name> patched`. The patch changes the pod template, so each Deployment makes a rollout. The labels are claims. Nothing checks that `probe` really meets the baseline, and it has no readiness probe, so the label is wrong for it. A label that is not verified is not evidence of adoption. A platform team reports adoption by combining the label with a check of the settings.

## Verify the claim

Count what meets each setting among the workloads that claim the path:

```sh
kubectl get deployments -A -l platform.starfleet.io/path=golden -o json | jq -r '.items[] | [.metadata.name, (.spec.template.spec.containers[0].readinessProbe != null), (.spec.template.spec.containers[0].resources.limits != null)] | @tsv'
```

The output has two rows. `scout` shows `true` and `true`. `probe` shows `false` and `true`. The label says two workloads are on the path, and the check says one of them is. A report that uses the check gives `1` and not `2`. Reporting the smaller number is the honest one, and it points at the work that remains: `probe` needs a probe, and its owner decides which endpoint to use.

## Exceptions are part of the design

Some workloads cannot follow the path. A legacy application may need to run as root, or a batch job has no HTTP endpoint for a probe. A platform that offers no way to say so gets dishonest labels or workarounds. A documented exception keeps the workload visible and keeps the reason. Record one for `shuttle`, which runs a shell loop with no HTTP endpoint:

```sh
kubectl -n starfleet label deployment shuttle platform.starfleet.io/path=exception
kubectl -n starfleet annotate deployment shuttle platform.starfleet.io/exception-reason="no HTTP endpoint to probe" platform.starfleet.io/exception-review="2027-01-31"
```

The commands print `deployment.apps/shuttle labeled` and `deployment.apps/shuttle annotated`. The annotations hold the reason and a date when the exception is reviewed. An exception without a review date stays forever. List the workloads with their path value:

```sh
kubectl get deployments -A -L platform.starfleet.io/path
```

The `PATH` column shows `golden` for `scout` and `probe`, `exception` for `shuttle`, and nothing for `drifter`. There are now three states: on the path, exception with a reason, and unknown. The unknown state is the one that the platform team follows up with the owner.

## Adoption as a report

A report turns these labels into numbers, and it can be recorded where the team and the platform both see it. Compute the counts from the cluster and store them:

```sh
total=$(kubectl get deployments -A -o json | jq '[.items[] | select(.metadata.namespace == "starfleet" or .metadata.namespace == "outpost")] | length')
golden=$(kubectl get deployments -A -l platform.starfleet.io/path=golden -o json | jq '[.items[] | select(.spec.template.spec.containers[0].readinessProbe != null)] | length')
exceptions=$(kubectl get deployments -A -l platform.starfleet.io/path=exception -o json | jq '.items | length')
kubectl -n starfleet create configmap adoption-report --from-literal=total=$total --from-literal=verified=$golden --from-literal=exceptions=$exceptions
kubectl -n starfleet get configmap adoption-report -o jsonpath='{.data}{"\n"}'
```

The last command prints a JSON object with `exceptions` `1`, `total` `4` and `verified` `1`. The numbers come from the cluster and not from memory, so a later run gives the new values. The `verified` count is the one that matters.

## Make the easy path the default

Adoption rises when the path is the first thing a team finds. Place the base where teams look, give it a short description of what it sets and what a team may change, and keep an example overlay next to it. Remove steps that do not add value, such as a request for approval of settings the path already guarantees. When the path is faster than the manual route, teams choose it without being told.

## Deprecate with notice

A path changes over time. A setting that was recommended last year may be wrong today. Mark the old version as deprecated, state a date, and tell the teams that use it. The label on the workloads lets the platform list exactly who is affected. Without a trace on the objects, the platform team cannot tell whom to notify.

## Feedback closes the loop

Numbers show where adoption stops, and they do not show why. Talk to the teams that did not adopt the path. The reasons point at the next change: a missing option in the overlay, a probe endpoint that does not fit, or documentation that is hard to find. Release the change in a small step, measure again and compare with the baseline. Small steps keep the path stable for the teams that already use it. Retire an old version of the path on a schedule that is announced, so that no team is surprised.

## What you know now

An optional path earns adoption, and a label on the workloads makes it visible. A label is a claim, so the report must verify the settings behind it. An exception with a reason and a review date keeps the workloads that cannot follow the path visible and honest. A report computed from the cluster shows verified adoption, exceptions and unknowns. The conversations with the teams explain the numbers, and the path improves in small, announced steps.

## Common pitfalls

> [!WARNING]
> A label is a claim and not proof. Count the verified settings.
> An exception without a reason and a review date becomes permanent and invisible.
> A mandate raises the count of the label and does not show that the path helps. Pair numbers with feedback.
