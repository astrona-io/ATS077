# Question

Solve this question on: `terminal`

The platform has three environments, the namespaces `dev`, `test` and `prod`, each with a ConfigMap `app-config`. `dev` has no limits on shared capacity, and the configuration of the three environments is not consistent.

1. Capacity in `dev`. Create a ResourceQuota `dev-quota` in `dev` with at most `4` pods, `requests.memory` of `256Mi` and `limits.memory` of `512Mi`. Create a LimitRange `dev-defaults` of type `Container` that gives every container a default memory limit of `64Mi` and a default memory request of `16Mi`.

2. A workload that uses the defaults. Create a Deployment `crew` in `dev` with the image `ghcr.io/stefanprodan/podinfo:6.15.0` and two replicas. Do not write resources in the Deployment. Both pods must run and carry the memory limit from the LimitRange.

3. Configuration parity. The ConfigMaps must have the same keys in every environment, with values that belong to the environment. `test` is missing the key `DATABASE_HOST`: give it the value `db.test.starfleet.internal`. `prod` must log at the level `warn`. Do not change the `DATABASE_HOST` of `prod`, and do not copy it into `test`.

Do not delete, scale down or replace `scout` or `shuttle`. `kubectl` already points at the cluster as the cluster administrator.
