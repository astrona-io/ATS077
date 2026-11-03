# Overview: Desired State, Rendering And Controllers (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. Declare something, change it by hand, look at what the controllers do, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator. `kubectl kustomize` and `kubectl apply -k` are part of `kubectl`, so you need no extra tool.
- The example workloads, each on a service account with its own name:

  | Namespace | Object | What it is |
  | --- | --- | --- |
  | `starfleet` | `scout`, `probe`, `shuttle` | The example application, one replica each |
  | `outpost` | `drifter` | A client that belongs to another team |

- Services `scout` and `probe` in `starfleet`. No Kustomize files exist: you write them on your own machine.

## Practice tasks

- Print `spec.replicas`, `status.readyReplicas`, `metadata.generation` and `status.observedGeneration` of `scout`. Scale it and print the four numbers again until they settle.
- Delete the `scout` pod, then delete the `scout` ReplicaSet, then delete the `scout` Deployment. Write down which object came back each time and why.
- Create a bare pod with `kubectl run`, delete it and explain why nothing recreates it.
- Write a base and an `outpost` overlay for `scout`. Run `kubectl kustomize`, `kubectl diff -k` and `kubectl apply -k`, then change the replica count in the overlay and diff again.
- Scale `outpost-scout` by hand, then run a server-side apply of the overlay output with `--field-manager=platform-team`. Read the conflict, then force it and look at `--show-managed-fields`.
