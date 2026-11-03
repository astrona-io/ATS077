# Question

Solve this question on: `terminal`

The `bridge-team` takes shared ownership of the `starfleet` workloads and wants feedback and guardrails before it deploys by itself. A review found three gaps.

1. Ownership. The running pods of `scout`, `probe` and `shuttle` in `starfleet` must carry the label `owner=bridge-team`. Put the label where the running pods get it from.

2. Feedback. The `probe` container has no readiness probe, so Kubernetes sends traffic to it as soon as it starts. Add an HTTP readiness probe to the `probe` container. The application answers `200` on the path `/status/200` on the container port named `http`. The Deployment must stay available.

3. Guardrail. The namespace `sandbox` must reject pods that do not meet the `restricted` Pod Security Standard. The Deployment `crew` in `sandbox` must keep running with a compliant security context. Its pods run `sh -c "while true; do sleep 30; done"` and need no write access to the file system and no special privileges. Use the numeric user ID `1000`.

Do not delete, scale down or replace `scout`, `probe` or `shuttle`. `kubectl` already points at the cluster as the cluster administrator.
