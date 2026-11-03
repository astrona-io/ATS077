# Overview: Platform Architecture (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. Create, break, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- The example workloads in `starfleet` (`scout`, `probe`, `shuttle`) and `outpost` (`drifter`).
- No custom resource definition, no admission policy and no team role exist yet.

## Practice tasks

- List the control plane pods in `kube-system` and run `kubectl get --raw '/readyz?verbose'`.
- Scale `scout` and watch its EndpointSlice change while the Service stays the same.
- Define a CRD with an enum, a number range and a CEL rule, then send valid and invalid objects with `--dry-run=server`.
- Write a status through the `status` subresource and compare it with an edit of `spec`.
- Create a ValidatingAdmissionPolicy and a binding that selects a namespace label, and test it inside and outside that namespace.
- Check `kubectl auth can-i` for a group that may create custom resources but not write their status.
