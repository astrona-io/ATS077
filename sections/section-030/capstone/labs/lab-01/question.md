# Question

Solve this question on: `terminal`

The platform runs three environments as the namespaces `dev`, `test` and `prod`. A review found three problems: the environments carry no guardrails, the `drifter-team` has more rights in production than it needs, and `test` shares production data. Fix all three without changing production data.

1. Guardrails. Label every namespace with `environment=<name>`, where the name is `dev`, `test` or `prod`. The namespace `prod` must enforce the `restricted` Pod Security Standard, and the other two must not enforce any standard. Create a ResourceQuota `test-quota` in `test` that allows at most `5` pods.

2. Access. The group `drifter-team` must be able to create and update Deployments in `dev` and `test`, and in `prod` it may only read workloads (pods and Deployments), and not Secrets and not change anything. At the moment it has the `edit` ClusterRole in all three namespaces. Change only what is too broad.

3. Data separation. `test` was seeded with the `DATABASE_HOST` of production in its ConfigMap `app-config`, and with the production password in its Secret `db-credentials`. Give `test` the host `db.test.starfleet.internal` and a password of your own that differs from production. Do not change any object in `prod`.

Do not delete, scale down or replace `scout` or `shuttle`. `kubectl` already points at the cluster as the cluster administrator. Check an identity with `kubectl auth can-i ... --as=<user> --as-group=drifter-team`.
