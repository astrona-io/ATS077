---
draft: true
exam_objectives:
- DevOps Practices in Platform Engineering
---
# Summary

DevOps joins the people who build a service with the people who run it. A team shares ownership of a service from design to production, deploys it by itself and learns quickly how it behaves. DevSecOps puts security checks in the same path, so that an unsafe change is stopped when it is made and not found in a review at the end. Shared ownership does not mean that everyone does everything. It means that a named team can see, change and answer for the service.

Ownership has to be visible in the system. Labels and annotations on the objects name the owning team, and labels in the pod template let monitoring, alerts and cost reports reach the owner. A label on a Deployment does not reach its pods, and the cluster does not check that a label names a real team. The label only helps when the team has agreed to the ownership and an on-call process exists.

A platform team treats the shared services as a product for the product teams. It owns the cluster, the pipeline, the base images and the policies, and the product team owns the application and its release decisions. Enablement means that a team can do the work itself through a supported interface, such as a role and a template. Handover means that the work waits in another team's queue. A clear written boundary avoids both a platform team that becomes a bottleneck and product teams that each rebuild the same setup.

Feedback tells the owner whether a change worked. The kubelet runs startup, liveness and readiness probes. Startup delays the other probes, liveness restarts a container and readiness removes a pod from traffic. A rolling update uses readiness to decide when old pods may go, so a new pod that never becomes ready leaves the old pod in service. The Deployment controller reports a stuck rollout with a condition, but it does not roll back. A person or a delivery tool runs the rollback, and the source of truth must be fixed as well.

Guardrails apply to every workload without a review. A security context sets the user, the privileges, the capabilities and the system-call filter of a container. Pod Security Admission checks each new pod against the standard that the namespace label selects, `privileged`, `baseline` or `restricted`, and rejects violations before the object is stored. It does not evict running pods, and a rejection shows up as an event of the ReplicaSet. Roles, role bindings, quotas and limit ranges complete the boundary, so a team deploys freely inside its namespace and cannot affect others.

Key facts:

- A pod label needs to be in the pod template to reach the pods.
- Liveness restarts, readiness removes from traffic and startup delays the other probes.
- A rollout waits when new pods do not become ready, and it does not roll back by itself.
- Pod Security Admission judges pods at creation or update, not while they run.
- A rejected pod appears as an event of the ReplicaSet, not as a failed Deployment.

<!-- astrona:playground:destroy -->
