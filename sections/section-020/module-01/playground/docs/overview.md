# Overview: Ownership, Feedback And Guardrails (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. Label, probe, break, roll back, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- The example workloads, each on a service account with its own name:

  | Namespace | Object | What it is |
  | --- | --- | --- |
  | `starfleet` | `scout`, `probe`, `shuttle` | The example application. Only `scout` has a readiness probe |
  | `outpost` | `drifter` | A client that belongs to another team |
  | `sandbox` | `crew` | A Deployment with no security context, for Pod Security experiments |

- No ownership labels, no Pod Security labels and no RoleBinding for any team exist yet.

## Practice tasks

- Add the label `owner=bridge-team` to the pod templates of `scout`, `probe` and `shuttle`, and select the pods with `-l owner=bridge-team`.
- Add a readiness probe to `probe`, then set an image tag that does not exist. Read the pod status, the events and the Deployment conditions, then use `kubectl rollout undo`.
- Run `kubectl label --dry-run=server --overwrite namespace sandbox pod-security.kubernetes.io/enforce=restricted` and read the warnings. Enforce the label, restart `crew` and find the rejection in the events.
- Fix `crew` so that it passes the `restricted` standard, then try the `baseline` standard on `outpost` and read what `drifter` violates, if anything.
- Bind the `edit` ClusterRole to a group in one namespace and check the answers of `kubectl auth can-i` in two namespaces with `--as` and `--as-group`.
