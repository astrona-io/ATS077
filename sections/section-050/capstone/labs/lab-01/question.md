# Question

Solve this question on: `terminal`

The platform team measures how many workloads follow the golden path. The namespace `adopt` holds three Deployments, all running the image `ghcr.io/stefanprodan/podinfo:6.15.0`. `bridge-web` follows the path. `engine-web` carries the label `platform.starfleet.io/path: golden`, but its settings do not match the label. `drifter-web` has no path label. Bring the namespace to an honest state and report it.

1. A workload is on the path when it has the label `platform.starfleet.io/path: golden` on the Deployment and on the pod template, a readiness probe (HTTP GET `/readyz` at port `http`), CPU and memory requests, a memory limit, a pod security context with `runAsNonRoot: true` and the `RuntimeDefault` seccomp profile, and a container security context with `allowPrivilegeEscalation: false` and all capabilities dropped. Bring `engine-web` onto the path without changing its image or deleting it. It must stay available.

2. `drifter-web` cannot follow the path. Do not change its settings. Record it as an exception: set the label `platform.starfleet.io/path=exception`, and add the annotations `platform.starfleet.io/exception-reason` (any non-empty text) and `platform.starfleet.io/exception-review` (a date).

3. Create the ConfigMap `adoption-report` in `adopt` with the keys `onpath`, `exceptions` and `total`. The values must match what the cluster shows: the number of Deployments that really meet the path, the number of documented exceptions, and the number of Deployments in the namespace. Derive the numbers with `kubectl` and `jq` instead of counting labels.

Do not delete, scale down or replace `scout`, `probe` or `shuttle`. `kubectl` already points at the cluster as the cluster administrator.
