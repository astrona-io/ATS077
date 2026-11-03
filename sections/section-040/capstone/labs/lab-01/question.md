# Question

Solve this question on: `terminal`

The CRD `apprequests.platform.starfleet.io` (kind `AppRequest`) already exists, and a service account `apprequest-controller` exists in `starfleet`. The platform team must now add guardrails and separate who may ask from who may report.

1. Replica cap. Create a ValidatingAdmissionPolicy `starfleet-replica-cap` that rejects Deployments with more than `3` replicas on create and update, with `failurePolicy: Fail`. Create a ValidatingAdmissionPolicyBinding `starfleet-replica-cap-binding` that denies violations in namespaces with the label `platform=managed`, and mark the namespace `starfleet` as managed. The namespace `outpost` stays unmanaged. The existing Deployments must keep working.

2. Team access. The group `drifter-team` must be able to create, get, list and watch AppRequests in `outpost`, and nothing else with them: no create in other namespaces, no update, no delete and no write of the status. Use a ClusterRole named `apprequest-submitter` and a RoleBinding named `drifter-team-submit` in `outpost`.

3. Controller access. The service account `apprequest-controller` in `starfleet` must be able to get, list and watch AppRequests in every namespace and to update and patch their status. It must not be able to create or delete AppRequests. Use a ClusterRole named `apprequest-controller` and a ClusterRoleBinding named `apprequest-controller`.

Do not delete, scale down or replace `scout` or `shuttle`. `kubectl` already points at the cluster as the cluster administrator. Test a policy with `kubectl create deployment ... --dry-run=server`, and a role with `kubectl auth can-i ... --as=...`.
