# Overview: Platform Goals And Golden Paths (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. Create, break, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- The example workloads in `starfleet` (`scout`, `probe`, `shuttle`) and `outpost` (`drifter`).
- `kubectl kustomize` and `kubectl apply -k` are built into `kubectl`. `jq` is available on the host.
- No golden path, no team namespace and no adoption label exist yet.

## Practice tasks

- Report which Deployments have a readiness probe, resource limits and an owner label, and count the ones without a probe.
- Write a Kustomize base with a Deployment and a Service, and render it with `kubectl kustomize`.
- Write two overlays that set a namespace, replicas and a team label, and compare the rendered output.
- Create a namespace with `pod-security.kubernetes.io/enforce=restricted` and apply a plain manifest and then the path.
- Label workloads with `platform.starfleet.io/path` and write a `jq` report that counts only those that really meet the settings.
- Record an exception with a reason and a review date on a workload that cannot follow the path.
