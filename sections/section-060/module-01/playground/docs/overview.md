# Overview: Build And Release Pipelines (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. Create, break, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- The example workloads in `starfleet` (`scout`, `probe`, `shuttle`) and `outpost` (`drifter`).
- The image `curlimages/curl:8.22.0` is preloaded, so a Job can run a shell command as a pipeline stage.
- No pipeline namespace, environment or release record exists yet.

## Practice tasks

- Run a Job that checks a ConfigMap mounted as a source revision, and wait for `complete`. Make a second Job fail on purpose and wait for `failed`.
- Write a build record as a ConfigMap and read the image digest from `status.containerStatuses[0].imageID` of a running pod.
- Create `staging` and `production` Deployments from one image variable, with a different ConfigMap in each.
- Add a release gate ConfigMap and a shell function that blocks until it says `approved=true`.
- Create a ServiceAccount and a Role limited to one namespace and test it with `kubectl auth can-i --as`.
- Release a change with `kubernetes.io/change-cause`, read `kubectl rollout history`, and undo it with `--to-revision`.
