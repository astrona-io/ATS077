---
draft: true
exam_objectives:
- Application Environments and Infrastructure Concepts
---
# Summary

An application environment is a purpose, such as development, test or production, with controls that make the purpose true. The name does not enforce anything. A cluster can implement environments as separate accounts, separate clusters or namespaces, and each choice separates different things. The right choice depends on what an incident in one environment may cost another, and the design must name which resources stay shared.

A namespace scopes the names of objects, and it is the scope of Roles, RoleBindings, quotas, limit ranges, ConfigMaps, Secrets and service accounts. It does not scope the network, the nodes, the kernel or the control plane. A pod can reach a Service in another namespace through its full DNS name unless a NetworkPolicy blocks it, and a NetworkPolicy has an effect only when the network plugin enforces it.

Shared capacity needs limits. A request is what the scheduler reserves, and a limit is the most a container may use. A memory limit is enforced by killing the container, and a CPU limit is enforced by slowing it down. A ResourceQuota caps the total of a namespace and rejects requests that would exceed it. A LimitRange fills in defaults and bounds, and it is applied before the quota check, so a quota on memory can still accept pods that declare nothing. The feedback appears as events of the ReplicaSet, not in the output of the command.

Identity and data follow the same rule: a missing binding is the boundary. A service account in one namespace has no rights in another unless a binding says so. Each environment keeps its own Secrets, and a copy of a production credential in a test namespace removes the separation. Base64 in a Secret is an encoding, not protection, so read access to a Secret is access to its value.

Configuration parity means that the same artifact moves through the environments, and what changes is configuration with the same set of keys and different values. A test result describes the artifact and the configuration that were tested, in that context. It does not prove that production traffic, permissions and every external dependency behave the same way.

Lifecycle completes the picture. Deleting a namespace removes every namespaced object in it, and nothing outside it. External databases, buckets and retained volumes stay until something removes them, so the cleanup rule must list what is temporary and what is kept.

Key facts:

- A namespace is a scope for names, permissions and quotas, and it is not a network or kernel boundary.
- A pod without requests is placed as if it needed nothing, and a quota on memory rejects it unless a default exists.
- A LimitRange applies only to pods created after it exists.
- A missing ConfigMap shows as `CreateContainerConfigError`, which is different from a crashing application.
- Deleting a namespace does not delete data stored outside the cluster.

<!-- astrona:playground:destroy -->
