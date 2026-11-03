# Overview: Environment Boundaries (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and three environment namespaces, and then waits. There is no task, no `astrona submit` and no pass or fail. Create, break, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- The example workloads in `starfleet` (`scout`, `probe`, `shuttle`) and `outpost` (`drifter`).
- Three environment namespaces:

  | Namespace | Label | ConfigMap `app-config` |
  | --- | --- | --- |
  | `dev` | `environment=dev` | `LOG_LEVEL=debug`, host `db.dev.starfleet.internal` |
  | `test` | `environment=test` | `LOG_LEVEL=info`, host `db.test.starfleet.internal` |
  | `prod` | `environment=prod` | `LOG_LEVEL=warn`, host `db.prod.starfleet.internal` |

- No quota, no limit range, no role binding and no Secret exist in the three namespaces yet.

## Practice tasks

- Run the same Deployment in `dev` and `test`, and call a Service in `dev` from `shuttle` by its full DNS name.
- Add a ResourceQuota to `test`, create a Deployment without resources and read the events. Add a LimitRange and watch the pods appear.
- Create a service account in `test`, bind `view` in that namespace, and check what it may do in `prod` with `kubectl auth can-i --as`.
- Create a pod that refers to a ConfigMap that does not exist and compare its status with a pod that crashes.
- Create a temporary namespace, put objects in it and delete it.
